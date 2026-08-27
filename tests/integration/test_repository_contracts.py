from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]


class RepositoryContractTests(unittest.TestCase):
    def test_mode_ids_are_shared_across_services(self) -> None:
        expected_modes = {"classic", "tournament", "jade", "sea_demon", "thrill_zone"}
        sources = [
            ROOT / "config.example" / "fishing-modes.yaml",
            ROOT / "admin" / "src" / "modeCatalog.js",
            ROOT / "server-python" / "app" / "models.py",
        ]
        for source in sources:
            content = source.read_text(encoding="utf-8")
            for mode in expected_modes:
                self.assertIn(mode, content, f"{mode} missing from {source}")

    def test_example_configuration_has_no_production_hosts(self) -> None:
        content = (ROOT / "config.example" / ".env.example").read_text(encoding="utf-8")
        self.assertIn("127.0.0.1", content)
        self.assertNotIn("password=", content.lower())


if __name__ == "__main__":
    unittest.main()
