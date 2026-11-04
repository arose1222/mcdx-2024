@IsTest
private class AccountOperationsTest {
  private static final String DEFAULT_DESCRIPTION = 'Default description';
  private static final String EXISTING_DESCRIPTION = 'Existing description';
  private static final String WHITESPACE_DESCRIPTION = ' \t ';
  private static final Integer BULK_SIZE = 251;

  @IsTest
  static void setDefaultDescriptionBlankDescriptionSetsDefaultAndReturnsSameInstance() {
    Account accountRecord = new Account(Name = 'Blank Account');

    Test.startTest();
    Account result = AccountOperations.setDefaultDescription(accountRecord);
    Test.stopTest();

    Assert.areEqual(
      DEFAULT_DESCRIPTION,
      accountRecord.Description,
      'A blank description is set to the default'
    );
    Assert.isTrue(accountRecord === result, 'The same account instance is returned');
    assertNoDataAccess();
  }

  @IsTest
  static void setDefaultDescriptionEmptyDescriptionSetsDefaultAndReturnsSameInstance() {
    Account accountRecord = new Account(Name = 'Empty Account', Description = '');

    Test.startTest();
    Account result = AccountOperations.setDefaultDescription(accountRecord);
    Test.stopTest();

    Assert.areEqual(
      DEFAULT_DESCRIPTION,
      accountRecord.Description,
      'An empty description is set to the default'
    );
    Assert.isTrue(accountRecord === result, 'The same account instance is returned');
    assertNoDataAccess();
  }

  @IsTest
  static void setDefaultDescriptionWhitespaceDescriptionSetsDefaultAndReturnsSameInstance() {
    Account accountRecord = new Account(
      Name = 'Whitespace Account',
      Description = WHITESPACE_DESCRIPTION
    );

    Test.startTest();
    Account result = AccountOperations.setDefaultDescription(accountRecord);
    Test.stopTest();

    Assert.areEqual(
      DEFAULT_DESCRIPTION,
      accountRecord.Description,
      'A whitespace description is set to the default'
    );
    Assert.isTrue(accountRecord === result, 'The same account instance is returned');
    assertNoDataAccess();
  }

  @IsTest
  static void setDefaultDescriptionExistingDescriptionLeavesTextAndReturnsSameInstance() {
    Account accountRecord = new Account(
      Name = 'Existing Account',
      Description = EXISTING_DESCRIPTION
    );

    Test.startTest();
    Account result = AccountOperations.setDefaultDescription(accountRecord);
    Test.stopTest();

    Assert.areEqual(
      EXISTING_DESCRIPTION,
      accountRecord.Description,
      'An existing description is left unchanged'
    );
    Assert.isTrue(accountRecord === result, 'The same account instance is returned');
    assertNoDataAccess();
  }

  @IsTest
  static void setDefaultDescriptionNullAccountReturnsNull() {
    Test.startTest();
    Account result = AccountOperations.setDefaultDescription((Account) null);
    Test.stopTest();

    Assert.isNull(result, 'A null account returns null');
    assertNoDataAccess();
  }

  @IsTest
  static void setDefaultDescriptionNullListReturnsEmptyList() {
    Test.startTest();
    List<Account> result = AccountOperations.setDefaultDescription((List<Account>) null);
    Test.stopTest();

    Assert.isNotNull(result, 'A null list returns a list');
    Assert.areEqual(0, result.size(), 'A null list returns an empty list');
    assertNoDataAccess();
  }

  @IsTest
  static void setDefaultDescriptionNullListEntrySkipsNullAndReturnsSameList() {
    Account blankAccount = new Account(Name = 'Blank Account');
    Account existingAccount = new Account(
      Name = 'Existing Account',
      Description = EXISTING_DESCRIPTION
    );
    List<Account> accounts = new List<Account>{ blankAccount, null, existingAccount };

    Test.startTest();
    List<Account> result = AccountOperations.setDefaultDescription(accounts);
    Test.stopTest();

    Assert.isTrue(accounts === result, 'The same list instance is returned');
    Assert.areEqual(3, result.size(), 'Null entries stay in the list');
    Assert.isNull(result[1], 'A null entry is skipped');
    Assert.isTrue(blankAccount === result[0], 'The blank account instance is kept');
    Assert.areEqual(
      DEFAULT_DESCRIPTION,
      blankAccount.Description,
      'A blank description is set to the default'
    );
    Assert.areEqual(
      EXISTING_DESCRIPTION,
      existingAccount.Description,
      'An existing description is left unchanged'
    );
    assertNoDataAccess();
  }

  @IsTest
  static void setDefaultDescriptionBulkMixAppliesRulesAndReturnsSameList() {
    List<Account> accounts = buildBulkMix();
    Map<String, Integer> expectedCounts = countBulkMix(accounts);

    Test.startTest();
    List<Account> result = AccountOperations.setDefaultDescription(accounts);
    Test.stopTest();

    Assert.isTrue(accounts === result, 'The same list instance is returned');
    Assert.areEqual(BULK_SIZE, result.size(), 'Every input row is retained');
    assertBulkMix(result, expectedCounts);
    assertNoDataAccess();
  }

  private static List<Account> buildBulkMix() {
    List<Account> accounts = new List<Account>();
    for (Integer index = 0; index < BULK_SIZE; index++) {
      Integer slot = Math.mod(index, 4);
      if (slot == 0) {
        accounts.add(new Account(Name = 'Blank ' + index));
      } else if (slot == 1) {
        accounts.add(
          new Account(Name = 'Whitespace ' + index, Description = WHITESPACE_DESCRIPTION)
        );
      } else if (slot == 2) {
        accounts.add(
          new Account(Name = 'Existing ' + index, Description = EXISTING_DESCRIPTION)
        );
      } else {
        accounts.add(null);
      }
    }
    return accounts;
  }

  private static Map<String, Integer> countBulkMix(List<Account> accounts) {
    Map<String, Integer> counts = new Map<String, Integer>{
      'blank' => 0,
      'whitespace' => 0,
      'existing' => 0,
      'null' => 0
    };
    for (Account accountRecord : accounts) {
      if (accountRecord == null) {
        counts.put('null', counts.get('null') + 1);
      } else if (accountRecord.Name.startsWith('Blank ')) {
        counts.put('blank', counts.get('blank') + 1);
      } else if (accountRecord.Name.startsWith('Whitespace ')) {
        counts.put('whitespace', counts.get('whitespace') + 1);
      } else {
        counts.put('existing', counts.get('existing') + 1);
      }
    }
    return counts;
  }

  private static void assertBulkMix(List<Account> accounts, Map<String, Integer> expectedCounts) {
    Map<String, Integer> seenCounts = new Map<String, Integer>{
      'blank' => 0,
      'whitespace' => 0,
      'existing' => 0,
      'null' => 0
    };
    for (Account accountRecord : accounts) {
      if (accountRecord == null) {
        seenCounts.put('null', seenCounts.get('null') + 1);
        continue;
      }
      if (accountRecord.Name.startsWith('Blank ')) {
        Assert.areEqual(
          DEFAULT_DESCRIPTION,
          accountRecord.Description,
          'A blank description is set to the default'
        );
        seenCounts.put('blank', seenCounts.get('blank') + 1);
      } else if (accountRecord.Name.startsWith('Whitespace ')) {
        Assert.areEqual(
          DEFAULT_DESCRIPTION,
          accountRecord.Description,
          'A whitespace description is set to the default'
        );
        seenCounts.put('whitespace', seenCounts.get('whitespace') + 1);
      } else {
        Assert.areEqual(
          EXISTING_DESCRIPTION,
          accountRecord.Description,
          'An existing description is left unchanged'
        );
        seenCounts.put('existing', seenCounts.get('existing') + 1);
      }
    }
    Assert.areEqual(expectedCounts.get('blank'), seenCounts.get('blank'), 'Every blank account is updated');
    Assert.areEqual(
      expectedCounts.get('whitespace'),
      seenCounts.get('whitespace'),
      'Every whitespace account is updated'
    );
    Assert.areEqual(
      expectedCounts.get('existing'),
      seenCounts.get('existing'),
      'Every existing description is kept'
    );
    Assert.areEqual(expectedCounts.get('null'), seenCounts.get('null'), 'Every null entry is skipped');
  }

  private static void assertNoDataAccess() {
    Assert.areEqual(0, Limits.getDmlStatements(), 'The helper performs no DML');
    Assert.areEqual(0, Limits.getQueries(), 'The helper performs no queries');
  }
}
