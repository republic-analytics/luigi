import re
import unittest

import luigi


class TestVersion(unittest.TestCase):

    # pattern -> https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
    SEMVAR_PATTERN = "^(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)(?:-(?P<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"  # noqa: E501 W605

    def test_pattern(self):
        # Arrange
        expected_major = 1
        expected_minor = 2
        expected_patch = 3
        expected_prerelease = "rc.4"
        expected_build = "build.5"
        version = f"{expected_major}.{expected_minor}.{expected_patch}-{expected_prerelease}+{expected_build}"
        # Act
        match = re.match(self.SEMVAR_PATTERN, version)
        # Assert
        self.assertIsNotNone(match)
        match_dict = match.groupdict()
        self.assertEqual(
            match_dict,
            {
                "major": str(expected_major),
                "minor": str(expected_minor),
                "patch": str(expected_patch),
                "prerelease": str(expected_prerelease),
                "buildmetadata": str(expected_build),
            }
        )

    def test_luigi_version(self):
        # Arrange
        # Act
        version = luigi.__version__
        # Assert
        self.assertIsInstance(version, str)
        match = re.match(self.SEMVAR_PATTERN, version)
        self.assertIsNotNone(match)
        required_elements = {"major", "minor", "patch"}
        for e in required_elements:
            val = match.group(e)
            self.assertIsInstance(val, str)
            self.assertTrue(val.isdigit())
