/**
 * @description Test class for TerritoryDashboardController_copado
 * @author Copado DevOps Demo
 * @date 2026-03-02
 */
@isTest
private class TerritoryDashboardController_copado_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test users
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testManager1 = new User(
            FirstName = 'Test',
            LastName = 'Manager One',
            Email = 'testmanager1@test.com',
            Username = 'testmanager1@test.copado.com',
            Alias = 'tmgr1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testManager1;
        
        User testManager2 = new User(
            FirstName = 'Test',
            LastName = 'Manager Two',
            Email = 'testmanager2@test.com',
            Username = 'testmanager2@test.copado.com',
            Alias = 'tmgr2',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testManager2;
        
        // Create test accounts with different statuses
        List<Account> testAccounts = new List<Account>();
        
        // Active accounts
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(
                Name = 'Active Account ' + i,
                Territory_Code__c = 'TER-CA-000' + i,
                Territory_Manager__c = testManager1.Id,
                Territory_Status__c = 'Active',
                Territory_Assignment_Date__c = Date.today()
            ));
        }
        
        // Pending accounts
        for (Integer i = 5; i < 8; i++) {
            testAccounts.add(new Account(
                Name = 'Pending Account ' + i,
                Territory_Code__c = 'TER-NY-000' + i,
                Territory_Status__c = 'Pending Review'
            ));
        }
        
        // Draft accounts
        for (Integer i = 8; i < 10; i++) {
            testAccounts.add(new Account(
                Name = 'Draft Account ' + i,
                Territory_Code__c = 'TER-TX-000' + i,
                Territory_Status__c = 'Draft'
            ));
        }
        
        insert testAccounts;
    }
    
    @isTest
    static void testGetTerritoryStatistics() {
        Test.startTest();
        
        TerritoryDashboardController_copado.TerritoryStats stats = 
            TerritoryDashboardController_copado.getTerritoryStatistics();
        
        Test.stopTest();
        
        // Verify statistics
        System.assertEquals(10, stats.totalAccounts, 'Total accounts should be 10');
        System.assertEquals(5, stats.activeAccounts, 'Active accounts should be 5');
        System.assertEquals(3, stats.pendingAccounts, 'Pending accounts should be 3');
        System.assertEquals(2, stats.draftAccounts, 'Draft accounts should be 2');
        System.assertNotEquals(null, stats.territories, 'Territories list should not be null');
        System.assertEquals(10, stats.territories.size(), 'Should have 10 territories');
    }
    
    @isTest
    static void testGetAccountsByTerritory() {
        Account testAccount = [SELECT Territory_Code__c FROM Account LIMIT 1];
        
        Test.startTest();
        
        List<Account> accounts = TerritoryDashboardController_copado.getAccountsByTerritory(
            testAccount.Territory_Code__c
        );
        
        Test.stopTest();
        
        System.assertNotEquals(null, accounts, 'Accounts list should not be null');
        System.assertEquals(1, accounts.size(), 'Should return 1 account for the territory');
        System.assertEquals(testAccount.Territory_Code__c, accounts[0].Territory_Code__c, 
            'Territory code should match');
    }
    
    @isTest
    static void testGetAccountsByStatus() {
        Test.startTest();
        
        List<Account> activeAccounts = TerritoryDashboardController_copado.getAccountsByStatus('Active');
        List<Account> pendingAccounts = TerritoryDashboardController_copado.getAccountsByStatus('Pending Review');
        List<Account> draftAccounts = TerritoryDashboardController_copado.getAccountsByStatus('Draft');
        
        Test.stopTest();
        
        System.assertEquals(5, activeAccounts.size(), 'Should return 5 active accounts');
        System.assertEquals(3, pendingAccounts.size(), 'Should return 3 pending accounts');
        System.assertEquals(2, draftAccounts.size(), 'Should return 2 draft accounts');
    }
    
    @isTest
    static void testReassignAccounts() {
        User newManager = [SELECT Id FROM User WHERE Username = 'testmanager2@test.copado.com' LIMIT 1];
        List<Account> accountsToReassign = [
            SELECT Id 
            FROM Account 
            WHERE Territory_Status__c = 'Pending Review'
            LIMIT 2
        ];
        
        List<Id> accountIds = new List<Id>();
        for (Account acc : accountsToReassign) {
            accountIds.add(acc.Id);
        }
        
        Test.startTest();
        
        Integer reassignedCount = TerritoryDashboardController_copado.reassignAccounts(
            accountIds, 
            newManager.Id
        );
        
        Test.stopTest();
        
        System.assertEquals(2, reassignedCount, 'Should reassign 2 accounts');
        
        // Verify reassignment
        List<Account> updatedAccounts = [
            SELECT Id, Territory_Manager__c, Territory_Status__c, Territory_Assignment_Date__c
            FROM Account
            WHERE Id IN :accountIds
        ];
        
        for (Account acc : updatedAccounts) {
            System.assertEquals(newManager.Id, acc.Territory_Manager__c, 
                'Territory Manager should be updated');
            System.assertEquals('Active', acc.Territory_Status__c, 
                'Territory Status should be Active');
            System.assertEquals(Date.today(), acc.Territory_Assignment_Date__c, 
                'Assignment date should be today');
        }
    }
    
    @isTest
    static void testGetAccountsByTerritoryNoResults() {
        Test.startTest();
        
        List<Account> accounts = TerritoryDashboardController_copado.getAccountsByTerritory('TER-ZZ-9999');
        
        Test.stopTest();
        
        System.assertNotEquals(null, accounts, 'Accounts list should not be null');
        System.assertEquals(0, accounts.size(), 'Should return 0 accounts for non-existent territory');
    }
    
    @isTest
    static void testReassignAccountsEmpty() {
        User newManager = [SELECT Id FROM User WHERE Username = 'testmanager2@test.copado.com' LIMIT 1];
        
        Test.startTest();
        
        Integer reassignedCount = TerritoryDashboardController_copado.reassignAccounts(
            new List<Id>(), 
            newManager.Id
        );
        
        Test.stopTest();
        
        System.assertEquals(0, reassignedCount, 'Should reassign 0 accounts when list is empty');
    }
    
    @isTest
    static void testBulkReassignment() {
        User newManager = [SELECT Id FROM User WHERE Username = 'testmanager2@test.copado.com' LIMIT 1];
        List<Account> allAccounts = [SELECT Id FROM Account];
        
        List<Id> accountIds = new List<Id>();
        for (Account acc : allAccounts) {
            accountIds.add(acc.Id);
        }
        
        Test.startTest();
        
        Integer reassignedCount = TerritoryDashboardController_copado.reassignAccounts(
            accountIds, 
            newManager.Id
        );
        
        Test.stopTest();
        
        System.assertEquals(10, reassignedCount, 'Should reassign all 10 accounts');
    }
}