#!/usr/bin/env ruby
# Unit tests for Casks/termix.rb
# This test suite validates the Homebrew Cask definition

require 'fileutils'

class TestFramework
  attr_reader :tests_run, :tests_passed, :tests_failed
  
  def initialize
    @tests_run = 0
    @tests_passed = 0
    @tests_failed = 0
  end
  
  def assert(condition, test_name)
    @tests_run += 1
    if condition
      @tests_passed += 1
      puts "\e[32m✓\e[0m PASS: #{test_name}"
    else
      @tests_failed += 1
      puts "\e[31m✗\e[0m FAIL: #{test_name}"
    end
  end
  
  def assert_equals(expected, actual, test_name)
    @tests_run += 1
    if expected == actual
      @tests_passed += 1
      puts "\e[32m✓\e[0m PASS: #{test_name}"
    else
      @tests_failed += 1
      puts "\e[31m✗\e[0m FAIL: #{test_name}"
      puts "  Expected: #{expected}"
      puts "  Actual:   #{actual}"
    end
  end
  
  def assert_matches(pattern, string, test_name)
    @tests_run += 1
    if string.match?(pattern)
      @tests_passed += 1
      puts "\e[32m✓\e[0m PASS: #{test_name}"
    else
      @tests_failed += 1
      puts "\e[31m✗\e[0m FAIL: #{test_name}"
      puts "  Pattern: #{pattern}"
      puts "  String:  #{string}"
    end
  end
  
  def assert_not_empty(value, test_name)
    @tests_run += 1
    if value && !value.to_s.empty?
      @tests_passed += 1
      puts "\e[32m✓\e[0m PASS: #{test_name}"
    else
      @tests_failed += 1
      puts "\e[31m✗\e[0m FAIL: #{test_name}"
      puts "  Value should not be empty"
    end
  end
  
  def print_summary
    puts "\n\e[33m========================================\e[0m"
    puts "\e[33mTest Summary\e[0m"
    puts "\e[33m========================================\e[0m"
    puts "Total tests run: #{@tests_run}"
    puts "\e[32mTests passed: #{@tests_passed}\e[0m"
    if @tests_failed > 0
      puts "\e[31mTests failed: #{@tests_failed}\e[0m"
      exit 1
    else
      puts "\e[32mAll tests passed!\e[0m"
      exit 0
    end
  end
end

class TermixCaskTest
  def initialize
    @test = TestFramework.new
    script_dir = File.dirname(File.expand_path(__FILE__))
    @repo_root = File.expand_path('../..', script_dir)
    @cask_file = File.join(@repo_root, 'Casks', 'termix.rb')
    @content = File.read(@cask_file) if File.exist?(@cask_file)
  end
  
  def run_all_tests
    puts "\e[33m========================================\e[0m"
    puts "\e[33mRunning Termix Cask Tests\e[0m"
    puts "\e[33m========================================\e[0m"
    
    test_file_exists
    test_file_structure
    test_cask_declaration
    test_version_field
    test_sha256_field
    test_url_field
    test_name_field
    test_desc_field
    test_homepage_field
    test_livecheck_block
    test_app_installation
    test_zap_trash
    test_syntax_validity
    test_url_format
    test_version_format
    test_sha256_format
    test_github_repository
    test_dmg_filename
    test_description_content
    test_trash_locations
    test_bundle_id
    test_livecheck_strategy
    
    @test.print_summary
  end
  
  private
  
  def test_file_exists
    puts "\n\e[33mTest Suite: File Existence\e[0m"
    @test.assert(File.exist?(@cask_file), "Cask file exists at Casks/termix.rb")
  end
  
  def test_file_structure
    puts "\n\e[33mTest Suite: File Structure\e[0m"
    @test.assert(@content.include?('cask'), "File contains cask definition")
    @test.assert(@content.include?('do'), "File contains do block")
    @test.assert(@content.include?('end'), "File contains end statement")
  end
  
  def test_cask_declaration
    @test.assert_matches(/^cask\s+"termix"\s+do/, @content, "Cask is declared with correct name")
  end
  
  def test_version_field
    puts "\n\e[33mTest Suite: Version Field\e[0m"
    @test.assert(@content.include?('version'), "Cask includes version field")
    version_match = @content.match(/version\s+"([^"]+)"/)
    @test.assert(version_match, "Version field has proper format")
    if version_match
      version = version_match[1]
      @test.assert_not_empty(version, "Version is not empty")
      @test.assert_matches(/^\d+\.\d+\.\d+$/, version, "Version follows semantic versioning (x.y.z)")
    end
  end
  
  def test_sha256_field
    puts "\n\e[33mTest Suite: SHA256 Field\e[0m"
    @test.assert(@content.include?('sha256'), "Cask includes sha256 field")
    sha_match = @content.match(/sha256\s+"([^"]+)"/)
    @test.assert(sha_match, "SHA256 field has proper format")
    if sha_match
      sha = sha_match[1]
      @test.assert_not_empty(sha, "SHA256 is not empty")
      @test.assert_equals(64, sha.length, "SHA256 is 64 characters long")
      @test.assert_matches(/^[a-f0-9]+$/, sha, "SHA256 contains only hex characters")
    end
  end
  
  def test_url_field
    puts "\n\e[33mTest Suite: URL Field\e[0m"
    @test.assert(@content.include?('url'), "Cask includes url field")
    @test.assert_matches(/url\s+"https:/, @content, "URL uses HTTPS protocol")
    @test.assert(@content.include?('github.com'), "URL points to GitHub")
  end
  
  def test_name_field
    puts "\n\e[33mTest Suite: Name Field\e[0m"
    @test.assert(@content.include?('name'), "Cask includes name field")
    @test.assert_matches(/name\s+"Termix"/, @content, "Name is set to 'Termix'")
  end
  
  def test_desc_field
    puts "\n\e[33mTest Suite: Description Field\e[0m"
    @test.assert(@content.include?('desc'), "Cask includes desc field")
    desc_match = @content.match(/desc\s+"([^"]+)"/)
    @test.assert(desc_match, "Description has proper format")
    if desc_match
      desc = desc_match[1]
      @test.assert(desc.length > 20, "Description is sufficiently detailed (>20 chars)")
      @test.assert(desc.include?('server') || desc.include?('SSH'), "Description mentions key features")
    end
  end
  
  def test_homepage_field
    puts "\n\e[33mTest Suite: Homepage Field\e[0m"
    @test.assert(@content.include?('homepage'), "Cask includes homepage field")
    @test.assert_matches(/homepage\s+"https:/, @content, "Homepage uses HTTPS")
    @test.assert(@content.include?('github.com/Termix-SSH/Termix'), "Homepage points to correct repository")
  end
  
  def test_livecheck_block
    puts "\n\e[33mTest Suite: Livecheck Configuration\e[0m"
    @test.assert(@content.include?('livecheck'), "Cask includes livecheck block")
    @test.assert(@content.include?('livecheck do'), "Livecheck block is properly opened")
    @test.assert_matches(/url\s+:url/, @content, "Livecheck uses :url symbol")
    @test.assert(@content.include?('strategy'), "Livecheck includes strategy")
    @test.assert(@content.include?(':github_latest'), "Livecheck uses github_latest strategy")
  end
  
  def test_app_installation
    puts "\n\e[33mTest Suite: App Installation\e[0m"
    @test.assert(@content.include?('app'), "Cask includes app directive")
    @test.assert_matches(/app\s+"Termix\.app"/, @content, "App directive specifies Termix.app")
  end
  
  def test_zap_trash
    puts "\n\e[33mTest Suite: Zap/Trash Configuration\e[0m"
    @test.assert(@content.include?('zap'), "Cask includes zap block")
    @test.assert(@content.include?('trash:'), "Zap includes trash directive")
    @test.assert(@content.include?('Library/Application Support/termix'), "Zap includes app support directory")
    @test.assert(@content.include?('Library/Caches/com.karmaa.termix'), "Zap includes cache directory")
    @test.assert(@content.include?('Library/Preferences/com.karmaa.termix.plist'), "Zap includes preferences")
    @test.assert(@content.include?('Library/Saved Application State'), "Zap includes saved state")
  end
  
  def test_syntax_validity
    puts "\n\e[33mTest Suite: Ruby Syntax\e[0m"
    # Test that the file can be parsed as Ruby
    begin
      eval("class TestCask; #{@content}; end")
      @test.assert(true, "Cask has valid Ruby syntax")
    rescue SyntaxError => e
      @test.assert(false, "Cask has valid Ruby syntax (Error: #{e.message})")
    end
  end
  
  def test_url_format
    puts "\n\e[33mTest Suite: URL Format\e[0m"
    @test.assert_matches(%r{/releases/download/release-#\{version\}-tag/}, @content, "URL uses version interpolation")
    @test.assert(@content.include?('termix_macos_universal_dmg.dmg'), "URL references universal DMG")
  end
  
  def test_version_format
    version_match = @content.match(/version\s+"([^"]+)"/)
    if version_match
      version = version_match[1]
      parts = version.split('.')
      @test.assert_equals(3, parts.length, "Version has three parts (major.minor.patch)")
      @test.assert(parts.all? { |p| p.match?(/^\d+$/) }, "All version parts are numeric")
    end
  end
  
  def test_sha256_format
    puts "\n\e[33mTest Suite: SHA256 Validation\e[0m"
    sha_match = @content.match(/sha256\s+"([^"]+)"/)
    if sha_match
      sha = sha_match[1]
      @test.assert(!sha.include?('PLACEHOLDER'), "SHA256 is not a placeholder")
      @test.assert(!sha.include?('TODO'), "SHA256 is not a TODO")
      @test.assert_matches(/^[0-9a-f]{64}$/, sha, "SHA256 is valid hexadecimal")
    end
  end
  
  def test_github_repository
    puts "\n\e[33mTest Suite: GitHub Repository Reference\e[0m"
    @test.assert(@content.include?('Termix-SSH/Termix'), "References correct GitHub repository")
    @test.assert(@content.include?('github.com/Termix-SSH/Termix'), "Full GitHub URL is correct")
  end
  
  def test_dmg_filename
    puts "\n\e[33mTest Suite: DMG Filename\e[0m"
    @test.assert(@content.include?('termix_macos_universal_dmg.dmg'), "DMG filename is correct")
    @test.assert(@content.include?('universal'), "DMG is universal binary")
  end
  
  def test_description_content
    puts "\n\e[33mTest Suite: Description Content\e[0m"
    desc_match = @content.match(/desc\s+"([^"]+)"/)
    if desc_match
      desc = desc_match[1].downcase
      @test.assert(desc.include?('ssh') || desc.include?('terminal'), "Description mentions SSH or terminal")
      @test.assert(desc.include?('server') || desc.include?('management'), "Description mentions server management")
    end
  end
  
  def test_trash_locations
    puts "\n\e[33mTest Suite: Trash Locations\e[0m"
    trash_count = @content.scan(/~\/Library/).length
    @test.assert(trash_count >= 4, "Zap includes multiple trash locations (found #{trash_count})")
    @test.assert(@content.include?('com.karmaa.termix.ShipIt'), "Includes ShipIt cache")
  end
  
  def test_bundle_id
    puts "\n\e[33mTest Suite: Bundle ID\e[0m"
    @test.assert(@content.include?('com.karmaa.termix'), "Uses consistent bundle ID")
    bundle_id_count = @content.scan(/com\.karmaa\.termix/).length
    @test.assert(bundle_id_count >= 3, "Bundle ID is used consistently (#{bundle_id_count} occurrences)")
  end
  
  def test_livecheck_strategy
    puts "\n\e[33mTest Suite: Livecheck Strategy\e[0m"
    @test.assert_matches(/strategy\s+:github_latest/, @content, "Uses github_latest strategy for version checking")
  end
end

# Run the tests
test_runner = TermixCaskTest.new
test_runner.run_all_tests