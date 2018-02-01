#encoding: UTF-8

@performance
Feature: System Performance testing

  @case_load
  Scenario: I run the Load test
    Given Test name "performance_load_test.jmx" run with the following table values
      | users | rampup | loop |
      | 25    | 5      | 1    |
    When The total number of Requests must be greater than "98"
    Then Throughput must be greater than "1"

