/**
 * @description Test class for TerritoryAssignmentService_copado and AccountTerritoryAssignment_copado trigger
 * @author Copado DevOps Demo
 * @date 2026-03-02
 */
@isTest
private class TerritoryAssignmentService_copado_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test users for territory managers
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testManager1 = new User(
            FirstName = 'Territory',
            LastName = 'Manager West',
            Email = 'territory.west@test.com',
            Username = 'territory.west@test.copado.com',
            Alias = 'tmwest',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testManager1;
        
        User testManager2 = new User(
            FirstName = 'Territory',
            LastName = 'Manager East',
            Email = 'territory.east@test.com',
            Username = 'territory.east@test.copado.com',
            Alias = 'tmeast',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testManager2;
    }
    
    @isTest
    static void testSingleAccountAssignment() {
        // Test single account with valid territory code
        Test.startTest();
        
        Account testAccount = new Account(
            Name = 'Test Account West',
            Territory_Code__c = 'TER-CA-0001'
        );
        insert testAccount;
        
        Test.stopTest();
        
        // Verify assignment
        Account result = [
            SELECT Id, Territory_Manager__c, Territory_Status__c, Territory_Assignment_Date__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];
        
        // Note: Without actual Custom Metadata records, manager will be null but status should be Pending Review
        System.assertEquals('Pending Review', result.Territory_Status__c, 
            'Territory Status should be Pending Review when code is valid but no manager mapping exists');
    }
    
    @isTest
    static void testBulkAccountAssignment() {
        // Test bulk processing with 200 accounts
        List<Account> bulkAccounts = new List<Account>();
        
        Test.startTest();
        
        for (Integer i = 0; i < 200; i++) {
            bulkAccounts.add(new Account(
                Name = 'Bulk Test Account ' + i,
                Territory_Code__c = 'TER-CA-' + String.valueOf(i).leftPad(4, '0')
            ));
        }
        insert bulkAccounts;
        
        Test.stopTest();
        
        // Verify all accounts were processed
        List<Account> results = [
            SELECT Id, Territory_Status__c
            FROM Account
            WHERE Id IN :bulkAccounts
        ];
        
        System.assertEquals(200, results.size(), 'All 200 accounts should be processed');
        
        // All should have a status assigned
        for (Account acc : results) {
            System.assertNotEquals(null, acc.Territory_Status__c, 
                'Territory Status should be set for all accounts');
        }
    }
    
    @isTest
    static void testInvalidTerritoryCodeValidation() {
        // Test validation rule prevents invalid territory code
        Test.startTest();
        
        Boolean exceptionCaught = false;
        try {
            Account testAccount = new Account(
                Name = 'Test Invalid Code',
                Territory_Code__c = 'INVALID-CODE'
            );
            insert testAccount;
        } catch (DmlException e) {
            exceptionCaught = true;
            System.assert(e.getMessage().contains('Territory Code must follow the format'), 
                'Validation rule should prevent invalid territory code');
        }
        
        Test.stopTest();
        
        System.assertEquals(true, exceptionCaught, 
            'DML Exception should be thrown for invalid territory code');
    }
    
    @isTest
    static void testTerritoryCodeUpdate() {
        // Test updating territory code on existing account
        Account testAccount = new Account(
            Name = 'Test Update Account',
            Territory_Code__c = 'TER-CA-0001'
        );
        insert testAccount;
        
        Test.startTest();
        
        // Update territory code
        testAccount.Territory_Code__c = 'TER-NY-0001';
        update testAccount;
        
        Test.stopTest();
        
        // Verify the update was processed
        Account result = [
            SELECT Id, Territory_Code__c, Territory_Status__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];
        
        System.assertEquals('TER-NY-0001', result.Territory_Code__c, 
            'Territory Code should be updated');
        System.assertNotEquals(null, result.Territory_Status__c, 
            'Territory Status should be set after update');
    }
    
    @isTest
    static void testNullTerritoryCode() {
        // Test with null/empty territory code
        Test.startTest();
        
        Account testAccount = new Account(
            Name = 'Test Null Code'
        );
        insert testAccount;
        
        Test.stopTest();
        
        // Verify no assignment occurred
        Account result = [
            SELECT Id, Territory_Manager__c, Territory_Status__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];
        
        System.assertEquals(null, result.Territory_Manager__c, 
            'Territory Manager should be null when no code provided');
    }
    
    @isTest
    static void testValidationMethod() {
        // Unit test for territory code validation method
        Test.startTest();
        
        // Valid codes
        System.assertEquals(true, 
            TerritoryAssignmentService_copado.validateTerritoryCode('TER-CA-0001'),
            'TER-CA-0001 should be valid');
        System.assertEquals(true, 
            TerritoryAssignmentService_copado.validateTerritoryCode('TER-NY-9999'),
            'TER-NY-9999 should be valid');
        
        // Invalid codes
        System.assertEquals(false, 
            TerritoryAssignmentService_copado.validateTerritoryCode('INVALID'),
            'INVALID should be invalid');
        System.assertEquals(false, 
            TerritoryAssignmentService_copado.validateTerritoryCode('TER-ca-0001'),
            'Lowercase letters should be invalid');
        System.assertEquals(false, 
            TerritoryAssignmentService_copado.validateTerritoryCode('TER-C-0001'),
            'Single letter region should be invalid');
        System.assertEquals(false, 
            TerritoryAssignmentService_copado.validateTerritoryCode('TER-CA-001'),
            'Three digit number should be invalid');
        System.assertEquals(false, 
            TerritoryAssignmentService_copado.validateTerritoryCode(null),
            'Null should be invalid');
        System.assertEquals(false, 
            TerritoryAssignmentService_copado.validateTerritoryCode(''),
            'Empty string should be invalid');
        
        Test.stopTest();
    }
    
    @isTest
    static void testMissingTerritoryMapping() {
        // Test valid code format but no Custom Metadata mapping exists
        Test.startTest();
        
        Account testAccount = new Account(
            Name = 'Test No Mapping',
            Territory_Code__c = 'TER-TX-0001'
        );
        insert testAccount;
        
        Test.stopTest();
        
        // Verify status is Pending Review (valid code but no manager)
        Account result = [
            SELECT Id, Territory_Status__c, Territory_Manager__c
            FROM Account
            WHERE Id = :testAccount.Id
        ];
        
        System.assertEquals('Pending Review', result.Territory_Status__c, 
            'Territory Status should be Pending Review when code is valid but no mapping exists');
        System.assertEquals(null, result.Territory_Manager__c, 
            'Territory Manager should be null when no mapping exists');
    }
}