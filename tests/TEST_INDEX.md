# Test Suite Index

## Quick Reference

| Test Suite | File | Language | Tests | Purpose |
|------------|------|----------|-------|---------|
| Update Cask | `unit/test_update_cask.sh` | Bash | 60+ | Validates update-cask.sh script |
| Build Flatpak | `unit/test_build_flatpak_bundle.sh` | Bash | 45+ | Validates build-flatpak-bundle.sh |
| Prepare Flatpak | `unit/test_prepare_flatpak.sh` | Bash | 40+ | Validates prepare-flatpak.sh |
| Cask Definition | `unit/test_termix_cask.rb` | Ruby | 50+ | Validates Homebrew Cask |
| JSON Configs | `validation/test_json_configs.py` | Python | 30+ | Validates JSON files |
| Flatpak Configs | `validation/test_flatpak_configs.py` | Python | 80+ | Validates YAML/XML |
| Integration | `integration/test_script_integration.sh` | Bash | 30+ | Cross-component tests |

## Test Execution

```bash
# All tests
./run_all_tests.sh

# Individual suites
./unit/test_update_cask.sh
./unit/test_build_flatpak_bundle.sh
./unit/test_prepare_flatpak.sh
./unit/test_termix_cask.rb
./validation/test_json_configs.py
./validation/test_flatpak_configs.py
./integration/test_script_integration.sh

# Demo
./demo_tests.sh
```

## Coverage Matrix

| File | Unit | Validation | Integration |
|------|------|------------|-------------|
| `update-cask.sh` | ✅ | - | ✅ |
| `Casks/termix.rb` | ✅ | - | ✅ |
| `flatpak/build-flatpak-bundle.sh` | ✅ | - | ✅ |
| `flatpak/prepare-flatpak.sh` | ✅ | - | ✅ |
| `.commitlintrc.json` | - | ✅ | - |
| `flatpak/flathub.json` | - | ✅ | - |
| `flatpak/com.karmaa.termix.yml` | - | ✅ | ✅ |
| `flatpak/com.karmaa.termix.metainfo.xml` | - | ✅ | - |
| `flatpak/com.karmaa.termix.desktop` | - | ✅ | - |
| `flatpak/com.karmaa.termix.flatpakref` | - | ✅ | - |

## Test Categories

### Unit Tests (4 suites, 195+ assertions)
Focus: Individual component validation
- Script structure and syntax
- Function-level logic
- Error handling
- Output formatting

### Validation Tests (2 suites, 110+ assertions)
Focus: Configuration file compliance
- JSON/YAML/XML syntax
- Schema validation
- Standard compliance (AppStream, etc.)
- Format validation

### Integration Tests (1 suite, 30+ assertions)
Focus: Component interaction
- Cross-file consistency
- Dependency verification
- End-to-end workflows
- System integration

## Total Statistics

- **Test Suites**: 7
- **Test Assertions**: 335+
- **Lines of Code**: 2,261
- **Files Covered**: 10
- **Languages**: Bash, Ruby, Python