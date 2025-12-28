#!/usr/bin/env python3
"""
Validation tests for JSON configuration files
This test suite validates JSON syntax and schema for configuration files
"""

import json
import os
import sys
from pathlib import Path

class Colors:
    GREEN = '\033[32m'
    RED = '\033[31m'
    YELLOW = '\033[33m'
    RESET = '\033[0m'

class TestFramework:
    def __init__(self):
        self.tests_run = 0
        self.tests_passed = 0
        self.tests_failed = 0
    
    def assert_true(self, condition, test_name):
        self.tests_run += 1
        if condition:
            self.tests_passed += 1
            print(f"{Colors.GREEN}✓{Colors.RESET} PASS: {test_name}")
            return True
        else:
            self.tests_failed += 1
            print(f"{Colors.RED}✗{Colors.RESET} FAIL: {test_name}")
            return False
    
    def assert_equals(self, expected, actual, test_name):
        self.tests_run += 1
        if expected == actual:
            self.tests_passed += 1
            print(f"{Colors.GREEN}✓{Colors.RESET} PASS: {test_name}")
            return True
        else:
            self.tests_failed += 1
            print(f"{Colors.RED}✗{Colors.RESET} FAIL: {test_name}")
            print(f"  Expected: {expected}")
            print(f"  Actual:   {actual}")
            return False
    
    def assert_in(self, item, container, test_name):
        self.tests_run += 1
        if item in container:
            self.tests_passed += 1
            print(f"{Colors.GREEN}✓{Colors.RESET} PASS: {test_name}")
            return True
        else:
            self.tests_failed += 1
            print(f"{Colors.RED}✗{Colors.RESET} FAIL: {test_name}")
            print(f"  '{item}' not found in {container}")
            return False
    
    def assert_is_instance(self, obj, expected_type, test_name):
        self.tests_run += 1
        if isinstance(obj, expected_type):
            self.tests_passed += 1
            print(f"{Colors.GREEN}✓{Colors.RESET} PASS: {test_name}")
            return True
        else:
            self.tests_failed += 1
            print(f"{Colors.RED}✗{Colors.RESET} FAIL: {test_name}")
            print(f"  Expected type: {expected_type}, Actual type: {type(obj)}")
            return False
    
    def print_summary(self):
        print(f"\n{Colors.YELLOW}========================================{Colors.RESET}")
        print(f"{Colors.YELLOW}Test Summary{Colors.RESET}")
        print(f"{Colors.YELLOW}========================================{Colors.RESET}")
        print(f"Total tests run: {self.tests_run}")
        print(f"{Colors.GREEN}Tests passed: {self.tests_passed}{Colors.RESET}")
        if self.tests_failed > 0:
            print(f"{Colors.RED}Tests failed: {self.tests_failed}{Colors.RESET}")
            return False
        else:
            print(f"{Colors.GREEN}All tests passed!{Colors.RESET}")
            return True

class JSONConfigTests:
    def __init__(self):
        self.test = TestFramework()
        script_dir = Path(__file__).parent
        self.repo_root = script_dir.parent.parent
        self.commitlint_file = self.repo_root / '.commitlintrc.json'
        self.flathub_file = self.repo_root / 'flatpak' / 'flathub.json'
    
    def run_all_tests(self):
        print(f"{Colors.YELLOW}========================================{Colors.RESET}")
        print(f"{Colors.YELLOW}Running JSON Configuration Tests{Colors.RESET}")
        print(f"{Colors.YELLOW}========================================{Colors.RESET}")
        
        self.test_commitlintrc_exists()
        self.test_commitlintrc_valid_json()
        self.test_commitlintrc_schema()
        self.test_commitlintrc_extends()
        self.test_commitlintrc_rules()
        self.test_commitlintrc_type_enum()
        self.test_commitlintrc_commit_types()
        self.test_commitlintrc_subject_case()
        
        self.test_flathub_exists()
        self.test_flathub_valid_json()
        self.test_flathub_schema()
        self.test_flathub_architectures()
        self.test_flathub_check_flags()
        
        return self.test.print_summary()
    
    # Commitlint tests
    def test_commitlintrc_exists(self):
        print(f"\n{Colors.YELLOW}Test Suite: Commitlint File{Colors.RESET}")
        self.test.assert_true(
            self.commitlint_file.exists(),
            "commitlintrc.json exists"
        )
    
    def test_commitlintrc_valid_json(self):
        try:
            with open(self.commitlint_file, 'r') as f:
                self.commitlint_data = json.load(f)
            self.test.assert_true(True, "commitlintrc.json is valid JSON")
        except json.JSONDecodeError as e:
            self.commitlint_data = None
            self.test.assert_true(False, f"commitlintrc.json is valid JSON (Error: {e})")
    
    def test_commitlintrc_schema(self):
        print(f"\n{Colors.YELLOW}Test Suite: Commitlint Schema{Colors.RESET}")
        if self.commitlint_data:
            self.test.assert_in('extends', self.commitlint_data, "Has 'extends' field")
            self.test.assert_in('rules', self.commitlint_data, "Has 'rules' field")
    
    def test_commitlintrc_extends(self):
        if self.commitlint_data:
            extends = self.commitlint_data.get('extends', [])
            self.test.assert_is_instance(extends, list, "'extends' is a list")
            self.test.assert_in(
                '@commitlint/config-conventional',
                extends,
                "Extends conventional config"
            )
    
    def test_commitlintrc_rules(self):
        if self.commitlint_data:
            rules = self.commitlint_data.get('rules', {})
            self.test.assert_is_instance(rules, dict, "'rules' is a dictionary")
            self.test.assert_in('type-enum', rules, "Has 'type-enum' rule")
            self.test.assert_in('subject-case', rules, "Has 'subject-case' rule")
    
    def test_commitlintrc_type_enum(self):
        print(f"\n{Colors.YELLOW}Test Suite: Commit Type Enum{Colors.RESET}")
        if self.commitlint_data:
            rules = self.commitlint_data.get('rules', {})
            type_enum = rules.get('type-enum', [])
            self.test.assert_is_instance(type_enum, list, "type-enum is a list")
            if len(type_enum) >= 3:
                self.test.assert_equals(2, type_enum[0], "type-enum severity is 2 (error)")
                self.test.assert_equals('always', type_enum[1], "type-enum is 'always' enforced")
                self.test.assert_is_instance(type_enum[2], list, "type-enum has list of types")
    
    def test_commitlintrc_commit_types(self):
        print(f"\n{Colors.YELLOW}Test Suite: Commit Types{Colors.RESET}")
        if self.commitlint_data:
            rules = self.commitlint_data.get('rules', {})
            type_enum = rules.get('type-enum', [])
            if len(type_enum) >= 3:
                types = type_enum[2]
                expected_types = ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'chore']
                for expected_type in expected_types:
                    self.test.assert_in(expected_type, types, f"Includes '{expected_type}' type")
    
    def test_commitlintrc_subject_case(self):
        print(f"\n{Colors.YELLOW}Test Suite: Subject Case Rule{Colors.RESET}")
        if self.commitlint_data:
            rules = self.commitlint_data.get('rules', {})
            subject_case = rules.get('subject-case', [])
            if len(subject_case) >= 1:
                self.test.assert_equals(0, subject_case[0], "subject-case is disabled (0)")
    
    # Flathub tests
    def test_flathub_exists(self):
        print(f"\n{Colors.YELLOW}Test Suite: Flathub Configuration{Colors.RESET}")
        self.test.assert_true(
            self.flathub_file.exists(),
            "flathub.json exists"
        )
    
    def test_flathub_valid_json(self):
        try:
            with open(self.flathub_file, 'r') as f:
                self.flathub_data = json.load(f)
            self.test.assert_true(True, "flathub.json is valid JSON")
        except json.JSONDecodeError as e:
            self.flathub_data = None
            self.test.assert_true(False, f"flathub.json is valid JSON (Error: {e})")
    
    def test_flathub_schema(self):
        print(f"\n{Colors.YELLOW}Test Suite: Flathub Schema{Colors.RESET}")
        if self.flathub_data:
            self.test.assert_in('only-arches', self.flathub_data, "Has 'only-arches' field")
            self.test.assert_in('skip-icons-check', self.flathub_data, "Has 'skip-icons-check' field")
            self.test.assert_in('skip-appstream-check', self.flathub_data, "Has 'skip-appstream-check' field")
    
    def test_flathub_architectures(self):
        print(f"\n{Colors.YELLOW}Test Suite: Architecture Configuration{Colors.RESET}")
        if self.flathub_data:
            arches = self.flathub_data.get('only-arches', [])
            self.test.assert_is_instance(arches, list, "'only-arches' is a list")
            self.test.assert_in('x86_64', arches, "Supports x86_64 architecture")
            self.test.assert_in('aarch64', arches, "Supports aarch64 architecture")
    
    def test_flathub_check_flags(self):
        print(f"\n{Colors.YELLOW}Test Suite: Check Flags{Colors.RESET}")
        if self.flathub_data:
            skip_icons = self.flathub_data.get('skip-icons-check')
            skip_appstream = self.flathub_data.get('skip-appstream-check')
            self.test.assert_is_instance(skip_icons, bool, "'skip-icons-check' is boolean")
            self.test.assert_is_instance(skip_appstream, bool, "'skip-appstream-check' is boolean")
            self.test.assert_equals(False, skip_icons, "Icons check is enabled")
            self.test.assert_equals(False, skip_appstream, "AppStream check is enabled")

if __name__ == '__main__':
    test_runner = JSONConfigTests()
    success = test_runner.run_all_tests()
    sys.exit(0 if success else 1)