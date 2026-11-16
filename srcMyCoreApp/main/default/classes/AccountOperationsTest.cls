@IsTest
private class AccountOperationsTest {
  private static final String DEFAULT_DESCRIPTION = 'Default description';
    private static final String EXISTING_DESCRIPTION = 'Key customer';

    @IsTest
    static void blankDescriptionGetsDefault() {
        Account acc = new Account(Name = 'Blank');

        Account result = AccountOperations.setDefaultDescription(acc);

        Assert.isTrue(acc === result, 'Expected the same Account instance');
        Assert.areEqual(DEFAULT_DESCRIPTION, result.Description);
    }

    @IsTest
    static void whitespaceDescriptionGetsDefault() {
        Account acc = new Account(Name = 'Whitespace', Description = '   ');

        Account result = AccountOperations.setDefaultDescription(acc);

        Assert.isTrue(acc === result, 'Expected the same Account instance');
        Assert.areEqual(DEFAULT_DESCRIPTION, result.Description);
    }

    @IsTest
    static void existingDescriptionIsKept() {
        Account acc = new Account(Name = 'Existing', Description = EXISTING_DESCRIPTION);

        Account result = AccountOperations.setDefaultDescription(acc);

        Assert.isTrue(acc === result, 'Expected the same Account instance');
        Assert.areEqual(EXISTING_DESCRIPTION, result.Description);
    }

    @IsTest
    static void nullAccountReturnsNull() {
        Account acc = null;

        Assert.isNull(AccountOperations.setDefaultDescription(acc));
    }

    @IsTest
    static void nullListReturnsEmptyList() {
        List<Account> accs = null;

        List<Account> result = AccountOperations.setDefaultDescription(accs);

        Assert.isNotNull(result, 'Expected an empty list, not null');
        Assert.isTrue(result.isEmpty(), 'Expected an empty list');
    }

    @IsTest
    static void nullEntryIsSkipped() {
        Account acc = new Account(Name = 'Blank');
        List<Account> accs = new List<Account>{ null, acc };

        List<Account> result = AccountOperations.setDefaultDescription(accs);

        Assert.isTrue(accs === result, 'Expected the same list instance');
        Assert.areEqual(2, result.size());
        Assert.isNull(result[0]);
        Assert.areEqual(DEFAULT_DESCRIPTION, result[1].Description);
    }

    @IsTest
    static void bulkMixedList() {
        List<Account> accs = new List<Account>();
        for (Integer i = 0; i < 251; i++) {
            switch on Math.mod(i, 4) {
                when 0 {
                    accs.add(new Account(Name = 'Blank ' + i));
                }
                when 1 {
                    accs.add(new Account(Name = 'Whitespace ' + i, Description = ' '));
                }
                when 2 {
                    accs.add(new Account(Name = 'Existing ' + i, Description = EXISTING_DESCRIPTION));
                }
                when else {
                    accs.add(null);
                }
            }
        }

        List<Account> result = AccountOperations.setDefaultDescription(accs);

        Assert.isTrue(accs === result, 'Expected the same list instance');
        Assert.areEqual(251, result.size());
        for (Integer i = 0; i < result.size(); i++) {
            Integer kind = Math.mod(i, 4);
            if (kind == 3) {
                Assert.isNull(result[i], 'Null entry should stay null at index ' + i);
            } else if (kind == 2) {
                Assert.areEqual(EXISTING_DESCRIPTION, result[i].Description, 'Index ' + i);
            } else {
                Assert.areEqual(DEFAULT_DESCRIPTION, result[i].Description, 'Index ' + i);
            }
        }
  }
}
