# coding: utf-8

require 'minitest/autorun'
require 'minitest/pride'

module FileUtils
  def create_shell_runner(cmd)
    show_command = cmd.join(" ")
    lambda do |ok, status|
      ok or
        fail "Command failed with status (#{status.exitstatus}): " +
        "[#{show_command}]"
    end
  end
  private :create_shell_runner
end

class ::TryRakeSh < ::Minitest::Test
  include ::FileUtils

  def test_if_a_command_exits_with_error_status_it_raises_a_runtime_error_and_fully_echoes_it_long
    string        = '1234567890' * 10
    error_message = 'Some error msg.'
    command       = build_command string, error_message
    assert_if_a_command_exits_with_error_status_it_raises_a_runtime_error_and_fully_echoes_it command, error_message
  end

  def test_if_a_command_exits_with_error_status_it_raises_a_runtime_error_and_fully_echoes_it_short
    string        = ''
    error_message = ''
    command       = build_command string, error_message
    assert_if_a_command_exits_with_error_status_it_raises_a_runtime_error_and_fully_echoes_it command, error_message
  end

  def test_if_a_command_exits_with_error_status_it_raises_a_runtime_error_and_prints_its_full_output_long
    string        = '1234567890' * 10
    error_message = 'Some error msg.'
    command       = build_command string, error_message
    assert_if_a_command_exits_with_error_status_it_raises_a_runtime_error_and_prints_its_full_output command, error_message
  end

  def test_if_a_command_exits_with_error_status_it_raises_a_runtime_error_and_prints_its_full_output_short
    string        = ''
    error_message = ''
    command       = build_command string, error_message
    assert_if_a_command_exits_with_error_status_it_raises_a_runtime_error_and_prints_its_full_output command, error_message
  end

  def test_if_a_command_exits_with_error_status_then_providing_a_block_fully_echoes_a_long_command
    string        = '1234567890' * 10
    error_message = 'Some error msg.'
    command       = build_command string, error_message
#print 'command='; p command
    actual_total_output = capture_subprocess_io do
      sh command do |ok, status|
      end
    end
# Stdout, stderr:
    expected_total_output = ['', "#{error_message}\n#{command}\n"]
    assert_equal expected_total_output, actual_total_output
  end

  private

  def build_command(string, error_message)
    string_clause = string.               empty? ? '' : %Q@v='#{string}';@
    stderr_clause =         error_message.empty? ? '' : %Q@$stderr.puts '#{error_message}';@
    exit_clause   =                                     %Q@exit false@
    %Q@ruby -e"#{string_clause}#{stderr_clause}#{exit_clause}"@
  end

  def assert_if_a_command_exits_with_error_status_it_raises_a_runtime_error_and_fully_echoes_it(command, error_message)
    exception = nil # Predefine to survive the block.
    capture_subprocess_io do
      exception = assert_raises RuntimeError do
        sh command
      end
    end
##  expected_error_message = %Q@Command failed with status (1): [#{command[0, 42] + '...'}]@
    expected_error_message = %Q@Command failed with status (1): [#{command}]@
    assert_equal expected_error_message, exception.message
  end

  def assert_if_a_command_exits_with_error_status_it_raises_a_runtime_error_and_prints_its_full_output(command, error_message)
    actual_total_output = capture_subprocess_io do
      assert_raises RuntimeError do
        sh command
      end
    end
    s = error_message.empty? ? '' : error_message + "\n"
    expected_total_output = ['', "#{s}#{command}\n"]
    assert_equal expected_total_output, actual_total_output
  end
end
