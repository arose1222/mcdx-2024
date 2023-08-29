@IsTest
private class AccountOperationsTest {
    @isTest static void setDefaultDescription(){
        Account acc = new Account(Name = 'My Test Account');
        insert acc;
        acc = AccountOperations.setDefaultDescription(acc);
    }
}