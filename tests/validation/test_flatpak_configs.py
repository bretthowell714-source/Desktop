#!/usr/bin/env python3
"""
Validation tests for Flatpak configuration files (YAML and XML)
This test suite validates the Flatpak manifest and metainfo files
"""

import os
import sys
import re
from pathlib import Path
from xml.etree import ElementTree as ET

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
    
    def assert_in(self, substring, string, test_name):
        self.tests_run += 1
        if substring in string:
            self.tests_passed += 1
            print(f"{Colors.GREEN}✓{Colors.RESET} PASS: {test_name}")
            return True
        else:
            self.tests_failed += 1
            print(f"{Colors.RED}✗{Colors.RESET} FAIL: {test_name}")
            print(f"  '{substring}' not found")
            return False
    
    def assert_not_empty(self, value, test_name):
        self.tests_run += 1
        if value and len(str(value).strip()) > 0:
            self.tests_passed += 1
            print(f"{Colors.GREEN}✓{Colors.RESET} PASS: {test_name}")
            return True
        else:
            self.tests_failed += 1
            print(f"{Colors.RED}✗{Colors.RESET} FAIL: {test_name}")
            print(f"  Value should not be empty")
            return False
    
    def assert_matches(self, pattern, string, test_name):
        self.tests_run += 1
        if re.search(pattern, string):
            self.tests_passed += 1
            print(f"{Colors.GREEN}✓{Colors.RESET} PASS: {test_name}")
            return True
        else:
            self.tests_failed += 1
            print(f"{Colors.RED}✗{Colors.RESET} FAIL: {test_name}")
            print(f"  Pattern '{pattern}' not found")
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

class FlatpakConfigTests:
    def __init__(self):
        self.test = TestFramework()
        script_dir = Path(__file__).parent
        self.repo_root = script_dir.parent.parent
        self.manifest_file = self.repo_root / 'flatpak' / 'com.karmaa.termix.yml'
        self.metainfo_file = self.repo_root / 'flatpak' / 'com.karmaa.termix.metainfo.xml'
        self.desktop_file = self.repo_root / 'flatpak' / 'com.karmaa.termix.desktop'
        self.flatpakref_file = self.repo_root / 'flatpak' / 'com.karmaa.termix.flatpakref'
    
    def run_all_tests(self):
        print(f"{Colors.YELLOW}========================================{Colors.RESET}")
        print(f"{Colors.YELLOW}Running Flatpak Configuration Tests{Colors.RESET}")
        print(f"{Colors.YELLOW}========================================{Colors.RESET}")
        
        # YAML Manifest tests
        self.test_manifest_exists()
        self.test_manifest_readable()
        self.test_manifest_app_id()
        self.test_manifest_runtime()
        self.test_manifest_sdk()
        self.test_manifest_base()
        self.test_manifest_command()
        self.test_manifest_finish_args()
        self.test_manifest_permissions()
        self.test_manifest_modules()
        self.test_manifest_build_commands()
        self.test_manifest_sources()
        self.test_manifest_architectures()
        self.test_manifest_checksums()
        
        # XML Metainfo tests
        self.test_metainfo_exists()
        self.test_metainfo_valid_xml()
        self.test_metainfo_component_type()
        self.test_metainfo_app_id()
        self.test_metainfo_name()
        self.test_metainfo_summary()
        self.test_metainfo_description()
        self.test_metainfo_licenses()
        self.test_metainfo_developer()
        self.test_metainfo_urls()
        self.test_metainfo_screenshots()
        self.test_metainfo_categories()
        self.test_metainfo_keywords()
        self.test_metainfo_releases()
        self.test_metainfo_content_rating()
        
        # Desktop file tests
        self.test_desktop_file_exists()
        self.test_desktop_file_format()
        
        # Flatpakref tests
        self.test_flatpakref_exists()
        self.test_flatpakref_format()
        
        return self.test.print_summary()
    
    # YAML Manifest Tests
    def test_manifest_exists(self):
        print(f"\n{Colors.YELLOW}Test Suite: Manifest File{Colors.RESET}")
        self.test.assert_true(
            self.manifest_file.exists(),
            "Flatpak manifest YAML file exists"
        )
    
    def test_manifest_readable(self):
        try:
            with open(self.manifest_file, 'r') as f:
                self.manifest_content = f.read()
            self.test.assert_true(True, "Manifest file is readable")
        except Exception as e:
            self.manifest_content = ""
            self.test.assert_true(False, f"Manifest file is readable (Error: {e})")
    
    def test_manifest_app_id(self):
        print(f"\n{Colors.YELLOW}Test Suite: Manifest App ID{Colors.RESET}")
        self.test.assert_in('app-id: com.karmaa.termix', self.manifest_content, "Has correct app-id")
    
    def test_manifest_runtime(self):
        print(f"\n{Colors.YELLOW}Test Suite: Manifest Runtime{Colors.RESET}")
        self.test.assert_in('runtime: org.freedesktop.Platform', self.manifest_content, "Uses freedesktop Platform runtime")
        self.test.assert_matches(r'runtime-version:\s*["\']?\d+\.\d+["\']?', self.manifest_content, "Has runtime version specified")
    
    def test_manifest_sdk(self):
        self.test.assert_in('sdk: org.freedesktop.Sdk', self.manifest_content, "Uses freedesktop SDK")
    
    def test_manifest_base(self):
        self.test.assert_in('base: org.electronjs.Electron2.BaseApp', self.manifest_content, "Uses Electron base app")
        self.test.assert_matches(r'base-version:\s*["\']?\d+\.\d+["\']?', self.manifest_content, "Has base version specified")
    
    def test_manifest_command(self):
        self.test.assert_in('command: termix', self.manifest_content, "Has correct command")
    
    def test_manifest_finish_args(self):
        print(f"\n{Colors.YELLOW}Test Suite: Finish Args (Permissions){Colors.RESET}")
        self.test.assert_in('finish-args:', self.manifest_content, "Has finish-args section")
    
    def test_manifest_permissions(self):
        permissions = [
            '--socket=x11',
            '--socket=wayland',
            '--share=network',
            '--share=ipc',
            '--filesystem=home',
            '--socket=ssh-auth'
        ]
        for perm in permissions:
            self.test.assert_in(perm, self.manifest_content, f"Grants {perm} permission")
    
    def test_manifest_modules(self):
        print(f"\n{Colors.YELLOW}Test Suite: Modules{Colors.RESET}")
        self.test.assert_in('modules:', self.manifest_content, "Has modules section")
        self.test.assert_in('- name: termix', self.manifest_content, "Has termix module")
    
    def test_manifest_build_commands(self):
        print(f"\n{Colors.YELLOW}Test Suite: Build Commands{Colors.RESET}")
        self.test.assert_in('build-commands:', self.manifest_content, "Has build-commands")
        self.test.assert_in('chmod +x termix.AppImage', self.manifest_content, "Makes AppImage executable")
        self.test.assert_in('--appimage-extract', self.manifest_content, "Extracts AppImage")
        self.test.assert_in('install -Dm755', self.manifest_content, "Installs binary with correct permissions")
    
    def test_manifest_sources(self):
        print(f"\n{Colors.YELLOW}Test Suite: Sources{Colors.RESET}")
        self.test.assert_in('sources:', self.manifest_content, "Has sources section")
        self.test.assert_in('type: file', self.manifest_content, "Uses file type sources")
        self.test.assert_in('url:', self.manifest_content, "Has URL specifications")
        self.test.assert_in('sha256:', self.manifest_content, "Has SHA256 checksums")
    
    def test_manifest_architectures(self):
        print(f"\n{Colors.YELLOW}Test Suite: Architecture Support{Colors.RESET}")
        self.test.assert_in('only-arches:', self.manifest_content, "Specifies architectures")
        self.test.assert_in('x86_64', self.manifest_content, "Supports x86_64")
        self.test.assert_in('aarch64', self.manifest_content, "Supports aarch64")
    
    def test_manifest_checksums(self):
        print(f"\n{Colors.YELLOW}Test Suite: Checksum Placeholders{Colors.RESET}")
        self.test.assert_in('CHECKSUM_X64_PLACEHOLDER', self.manifest_content, "Has x64 checksum placeholder")
        self.test.assert_in('CHECKSUM_ARM64_PLACEHOLDER', self.manifest_content, "Has ARM64 checksum placeholder")
        self.test.assert_in('VERSION_PLACEHOLDER', self.manifest_content, "Has version placeholder")
    
    # XML Metainfo Tests
    def test_metainfo_exists(self):
        print(f"\n{Colors.YELLOW}Test Suite: Metainfo File{Colors.RESET}")
        self.test.assert_true(
            self.metainfo_file.exists(),
            "Metainfo XML file exists"
        )
    
    def test_metainfo_valid_xml(self):
        try:
            self.tree = ET.parse(self.metainfo_file)
            self.root = self.tree.getroot()
            self.test.assert_true(True, "Metainfo is valid XML")
        except ET.ParseError as e:
            self.tree = None
            self.root = None
            self.test.assert_true(False, f"Metainfo is valid XML (Error: {e})")
    
    def test_metainfo_component_type(self):
        print(f"\n{Colors.YELLOW}Test Suite: Component Type{Colors.RESET}")
        if self.root is not None:
            self.test.assert_equals(
                'desktop-application',
                self.root.get('type'),
                "Component type is desktop-application"
            )
    
    def test_metainfo_app_id(self):
        print(f"\n{Colors.YELLOW}Test Suite: Metainfo App ID{Colors.RESET}")
        if self.root is not None:
            app_id = self.root.find('id')
            self.test.assert_true(app_id is not None, "Has <id> element")
            if app_id is not None:
                self.test.assert_equals('com.karmaa.termix', app_id.text, "App ID matches")
    
    def test_metainfo_name(self):
        print(f"\n{Colors.YELLOW}Test Suite: App Name{Colors.RESET}")
        if self.root is not None:
            name = self.root.find('name')
            self.test.assert_true(name is not None, "Has <name> element")
            if name is not None:
                self.test.assert_equals('Termix', name.text, "Name is 'Termix'")
    
    def test_metainfo_summary(self):
        print(f"\n{Colors.YELLOW}Test Suite: Summary{Colors.RESET}")
        if self.root is not None:
            summary = self.root.find('summary')
            self.test.assert_true(summary is not None, "Has <summary> element")
            if summary is not None:
                self.test.assert_not_empty(summary.text, "Summary is not empty")
                self.test.assert_true(
                    len(summary.text) < 200,
                    f"Summary is concise (length: {len(summary.text)})"
                )
    
    def test_metainfo_description(self):
        print(f"\n{Colors.YELLOW}Test Suite: Description{Colors.RESET}")
        if self.root is not None:
            description = self.root.find('description')
            self.test.assert_true(description is not None, "Has <description> element")
            if description is not None:
                paragraphs = description.findall('p')
                self.test.assert_true(len(paragraphs) > 0, "Description has paragraphs")
                ul_elements = description.findall('ul')
                self.test.assert_true(len(ul_elements) > 0, "Description has feature list")
                if ul_elements:
                    li_elements = ul_elements[0].findall('li')
                    self.test.assert_true(len(li_elements) >= 3, f"Has multiple features listed ({len(li_elements)} items)")
    
    def test_metainfo_licenses(self):
        print(f"\n{Colors.YELLOW}Test Suite: Licenses{Colors.RESET}")
        if self.root is not None:
            metadata_license = self.root.find('metadata_license')
            project_license = self.root.find('project_license')
            self.test.assert_true(metadata_license is not None, "Has metadata_license")
            self.test.assert_true(project_license is not None, "Has project_license")
            if metadata_license is not None:
                self.test.assert_equals('CC0-1.0', metadata_license.text, "Metadata license is CC0-1.0")
            if project_license is not None:
                self.test.assert_in('GPL', project_license.text, "Project uses GPL license")
    
    def test_metainfo_developer(self):
        print(f"\n{Colors.YELLOW}Test Suite: Developer Info{Colors.RESET}")
        if self.root is not None:
            developer = self.root.find('developer_name')
            self.test.assert_true(developer is not None, "Has developer_name")
            if developer is not None:
                self.test.assert_not_empty(developer.text, "Developer name is not empty")
    
    def test_metainfo_urls(self):
        print(f"\n{Colors.YELLOW}Test Suite: URLs{Colors.RESET}")
        if self.root is not None:
            url_types = ['homepage', 'bugtracker', 'help', 'vcs-browser']
            for url_type in url_types:
                url_elem = self.root.find(f"url[@type='{url_type}']")
                self.test.assert_true(url_elem is not None, f"Has {url_type} URL")
                if url_elem is not None:
                    self.test.assert_true(
                        url_elem.text.startswith('http'),
                        f"{url_type} URL is valid"
                    )
    
    def test_metainfo_screenshots(self):
        print(f"\n{Colors.YELLOW}Test Suite: Screenshots{Colors.RESET}")
        if self.root is not None:
            screenshots = self.root.find('screenshots')
            self.test.assert_true(screenshots is not None, "Has screenshots section")
            if screenshots is not None:
                screenshot_list = screenshots.findall('screenshot')
                self.test.assert_true(len(screenshot_list) > 0, "Has at least one screenshot")
                if screenshot_list:
                    default_screenshot = screenshots.find("screenshot[@type='default']")
                    self.test.assert_true(default_screenshot is not None, "Has default screenshot")
                    image = screenshot_list[0].find('image')
                    self.test.assert_true(image is not None, "Screenshot has image URL")
                    caption = screenshot_list[0].find('caption')
                    self.test.assert_true(caption is not None, "Screenshot has caption")
    
    def test_metainfo_categories(self):
        print(f"\n{Colors.YELLOW}Test Suite: Categories{Colors.RESET}")
        if self.root is not None:
            categories = self.root.find('categories')
            self.test.assert_true(categories is not None, "Has categories section")
            if categories is not None:
                category_list = categories.findall('category')
                self.test.assert_true(len(category_list) >= 2, f"Has multiple categories ({len(category_list)})")
                category_texts = [c.text for c in category_list]
                expected_categories = ['Development', 'Network', 'System']
                for expected in expected_categories:
                    self.test.assert_in(
                        expected,
                        category_texts,
                        f"Includes '{expected}' category"
                    )
    
    def test_metainfo_keywords(self):
        print(f"\n{Colors.YELLOW}Test Suite: Keywords{Colors.RESET}")
        if self.root is not None:
            keywords = self.root.find('keywords')
            self.test.assert_true(keywords is not None, "Has keywords section")
            if keywords is not None:
                keyword_list = keywords.findall('keyword')
                self.test.assert_true(len(keyword_list) >= 3, f"Has multiple keywords ({len(keyword_list)})")
                keyword_texts = [k.text for k in keyword_list]
                self.test.assert_in('ssh', keyword_texts, "Includes 'ssh' keyword")
                self.test.assert_in('terminal', keyword_texts, "Includes 'terminal' keyword")
    
    def test_metainfo_releases(self):
        print(f"\n{Colors.YELLOW}Test Suite: Releases{Colors.RESET}")
        if self.root is not None:
            releases = self.root.find('releases')
            self.test.assert_true(releases is not None, "Has releases section")
            if releases is not None:
                release_list = releases.findall('release')
                self.test.assert_true(len(release_list) > 0, "Has at least one release")
                if release_list:
                    release = release_list[0]
                    self.test.assert_true(release.get('version') is not None, "Release has version attribute")
                    self.test.assert_true(release.get('date') is not None, "Release has date attribute")
    
    def test_metainfo_content_rating(self):
        print(f"\n{Colors.YELLOW}Test Suite: Content Rating{Colors.RESET}")
        if self.root is not None:
            content_rating = self.root.find('content_rating')
            self.test.assert_true(content_rating is not None, "Has content_rating")
            if content_rating is not None:
                self.test.assert_equals('oars-1.1', content_rating.get('type'), "Uses OARS 1.1 rating system")
    
    # Desktop File Tests
    def test_desktop_file_exists(self):
        print(f"\n{Colors.YELLOW}Test Suite: Desktop Entry File{Colors.RESET}")
        self.test.assert_true(
            self.desktop_file.exists(),
            "Desktop entry file exists"
        )
    
    def test_desktop_file_format(self):
        if self.desktop_file.exists():
            with open(self.desktop_file, 'r') as f:
                desktop_content = f.read()
            self.test.assert_in('[Desktop Entry]', desktop_content, "Has [Desktop Entry] section")
            self.test.assert_in('Type=', desktop_content, "Specifies Type")
            self.test.assert_in('Name=', desktop_content, "Has Name field")
            self.test.assert_in('Exec=', desktop_content, "Has Exec command")
            self.test.assert_in('Icon=', desktop_content, "Has Icon field")
    
    # Flatpakref Tests
    def test_flatpakref_exists(self):
        print(f"\n{Colors.YELLOW}Test Suite: Flatpakref File{Colors.RESET}")
        self.test.assert_true(
            self.flatpakref_file.exists(),
            "Flatpakref file exists"
        )
    
    def test_flatpakref_format(self):
        if self.flatpakref_file.exists():
            with open(self.flatpakref_file, 'r') as f:
                flatpakref_content = f.read()
            self.test.assert_in('[Flatpak Ref]', flatpakref_content, "Has [Flatpak Ref] section")
            self.test.assert_in('Name=', flatpakref_content, "Has Name field")
            self.test.assert_in('Branch=', flatpakref_content, "Has Branch field")
            self.test.assert_in('Url=', flatpakref_content, "Has Url field")

if __name__ == '__main__':
    test_runner = FlatpakConfigTests()
    success = test_runner.run_all_tests()
    sys.exit(0 if success else 1)