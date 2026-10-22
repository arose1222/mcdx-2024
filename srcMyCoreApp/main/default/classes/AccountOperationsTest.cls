@IsTest
private class AccountOperationsTest {
  @IsTest
  static void setDefaultDescriptionAssignsDefaultAndReturnsSameInstance() {
    Account accountRecord = new Account(Name = 'My Test Account');

    Account result = AccountOperations.setDefaultDescription(accountRecord);

    System.assertEquals(
      'Default description',
      accountRecord.Description,
      'A blank description is set to the default'
    );
    System.assert(accountRecord === result, 'The same instance is returned');
  }

  @IsTest
  static void setDefaultDescriptionOverwritesExistingDescription() {
    Account accountRecord = new Account(
      Name = 'My Test Account',
      Description = 'Existing description'
    );

    Account result = AccountOperations.setDefaultDescription(accountRecord);

    System.assertEquals(
      'Default description',
      accountRecord.Description,
      'An existing description is overwritten'
    );
    System.assert(accountRecord === result, 'The same instance is returned');
  }

  @IsTest
  static void setDefaultDescriptionReturnsNullForNullArgument() {
    Account result = AccountOperations.setDefaultDescription(null);

    System.assertEquals(null, result, 'A null argument returns null');
  }
}
