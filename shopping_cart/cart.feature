Feature: Shopping cart
  As a consumer
  I want a shopping cart
  So that I can manage my checkout

  Scenario: User adds an item to the shopping cart
    Given I am viewing an item
    When I want the item
    Then I should be able to add it to my cart

  Scenario: User removes an item to the shopping cart
    Given I am viewing my cart
    When I do not want the item
    Then I should be able to remove it from my cart

  Scenario: User updates an item quantity
    Given I am viewing my cart
    Then I should be able to change the item quantity

  Scenario: User wants to view an item from the shopping cart
    Given I am viewing my cart
    Then I should be able to view an item's page

  Scenario: User wants to view shipping charges from the shopping cart
    Given I am viewing my cart
    Then I should be able to get shipping price by entering my address

  Scenario: User adds a valid coupon to adjust subtotal in the cart
    Given I am viewing my cart
    When I enter a valid coupon code
    Then I should see my adjusted subtotal

  Scenario: User adds an expired coupon to adjust subtotal in the cart
    Given I am viewing my cart
    When I enter an expired coupon code
    Then I should see a message indicating expired
    And I should not see a change in subtotal

  Scenario: Logging in after anonymous cart not empty
    Given I have added items as an anonymous user
    When I login successfully
    Then I should see my anonymously added items with my previous session items

  Scenario: User adds the same SKU that is already presesnt in the cart
    Given I have added an item
    When I add the same item again
    Then I should see that item with quantity equal to two
