/**
 * @description Test class for TerritoryAssignmentService_copado
 * @author Copado DevOps Demo
 * @date 2026-03-09
 */
@isTest
private class TerritoryAssignmentService_copado_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test users for territory and regional managers
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User territoryManager1 = new User(
            FirstName = 'Territory',
            LastName = 'Manager NA',
            Email = 'territory.na@test.com',
            Username = 'territory.na@test.copado.com.' + System.currentTimeMillis(),
            Alias = 'tmna',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        
        User regionalManager1 = new User(
            FirstName = 'Regional',
            LastName = 'Manager NA',
            Email = 'regional.na@test.com',
            Username = 'regional.na@test.copado.com.' + System.currentTimeMillis(),
            Alias = 'rmna',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        
        insert new List<User>{territoryManager1, regionalManager1};
    }
    
    @isTest
    static void testValidTerritoryCodeFormat() {
        // Test valid territory codes
        System.assert(
            TerritoryAssignmentService_copado.validateTerritoryCode('TER-US-0001'),
            'Valid territory code should pass validation'
        );
        System.assert(
            TerritoryAssignmentService_copado.validateTerritoryCode('TER-GB-9999'),
            'Valid territory code should pass validation'
        );
        
        // Test invalid territory codes
        System.assert(
            !TerritoryAssignmentService_copado.validateTerritoryCode('TER-US-001'),
            'Invalid territory code should fail validation'
        );
        System.assert(
            !TerritoryAssignmentService_copado.validateTerritoryCode('TER-USA-0001'),
            'Invalid territory code should fail validation'
        );
        System.assert(
            !TerritoryAssignmentService_copado.validateTerritoryCode(''),
            'Empty territory code should fail validation'
        );
        System.assert(
            !TerritoryAssignmentService_copado.validateTerritoryCode(null),
            'Null territory code should fail validation'
        );
    }
    
    @isTest
    static void testRegionDerivation() {
        // Test North America
        System.assertEquals('NA', 
            TerritoryAssignmentService_copado.deriveRegionFromTerritoryCode('TER-US-0001'),
            'US should map to NA region'
        );
        System.assertEquals('NA', 
            TerritoryAssignmentService_copado.deriveRegionFromTerritoryCode('TER-CA-0001'),
            'CA should map to NA region'
        );
        System.assertEquals('NA', 
            TerritoryAssignmentService_copado.deriveRegionFromTerritoryCode('TER-MX-0001'),
            'MX should map to NA region'
        );
        
        // Test LATAM
        System.assertEquals('LATAM', 
            TerritoryAssignmentService_copado.deriveRegionFromTerritoryCode('TER-BR-0001'),
            'BR should map to LATAM region'
        );
        System.assertEquals('LATAM', 
            TerritoryAssignmentService_copado.deriveRegionFromTerritoryCode('TER-AR-0001'),
            'AR should map to LATAM region'
        );
        
        // Test EMEA
        System.assertEquals('EMEA', 
            TerritoryAssignmentService_copado.deriveRegionFromTerritoryCode('TER-GB-0001'),
            'GB should map to EMEA region'
        );
        System.assertEquals('EMEA', 
            TerritoryAssignmentService_copado.deriveRegionFromTerritoryCode('TER-DE-0001'),
            'DE should map to EMEA region'
        );
        
        // Test APAC
        System.assertEquals('APAC', 
            TerritoryAssignmentService_copado.deriveRegionFromTerritoryCode('TER-AU-0001'),
            'AU should map to APAC region'
        );
        System.assertEquals('APAC', 
            TerritoryAssignmentService_copado.deriveRegionFromTerritoryCode('TER-JP-0001'),
            'JP should map to APAC region'
        );
        
        // Test invalid code
        System.assertEquals(null, 
            TerritoryAssignmentService_copado.deriveRegionFromTerritoryCode('INVALID'),
            'Invalid code should return null'
        );
        
        // Test unknown country code
        System.assertEquals(null, 
            TerritoryAssignmentService_copado.deriveRegionFromTerritoryCode('TER-XX-0001'),
            'Unknown country code should return null'
        );
    }
    
    @isTest
    static void testAccountAssignmentWithRegion() {
        // Note: This test assumes Custom Metadata records exist for TER-US-0001
        // In a real scenario, you would need to create test metadata or use dependency injection
        
        Test.startTest();
        
        Account testAccount = new Account(
            Name = 'Test Account NA',
            Territory_Code__c = 'TER-US-0001'
        );
        insert testAccount;
        
        Test.stopTest();
        
        // Query the account to verify assignments
        Account updatedAccount = [
            SELECT Territory_Code__c, Territory_Manager__c, Region__c, 
                   Territory_Status__c, Regional_Manager__c
            FROM Account 
            WHERE Id = :testAccount.Id
        ];
        
        // Verify territory code is set
        System.assertEquals('TER-US-0001', updatedAccount.Territory_Code__c);
        
        // Region should be derived even if no Custom Metadata exists
        System.assertEquals('NA', updatedAccount.Region__c, 'Region should be derived from territory code');
        
        // If Custom Metadata exists, verify assignments
        // Otherwise, verify status is Pending Review
        if (updatedAccount.Territory_Manager__c != null) {
            System.assertEquals('Active', updatedAccount.Territory_Status__c);
        } else {
            System.assertEquals('Pending Review', updatedAccount.Territory_Status__c);
        }
    }
    
    @isTest
    static void testAccountAssignmentWithMockData() {
        // Get test users
        User territoryManager = [SELECT Id FROM User WHERE LastName = 'Manager NA' AND FirstName = 'Territory' LIMIT 1];
        User regionalManager = [SELECT Id FROM User WHERE LastName = 'Manager NA' AND FirstName = 'Regional' LIMIT 1];
        
        // Enable test mode and inject mock mappings
        TerritoryAssignmentService_copado.testMode = true;
        TerritoryAssignmentService_copado.testMappings.put(
            'TER-CA-0001',
            new TerritoryAssignmentService_copado.TerritoryMapping(
                territoryManager.Id,
                'NA',
                regionalManager.Id
            )
        );
        
        Test.startTest();
        
        Account testAccount = new Account(
            Name = 'Test Account Canada',
            Territory_Code__c = 'TER-CA-0001'
        );
        insert testAccount;
        
        Test.stopTest();
        
        // Query the account to verify assignments
        Account updatedAccount = [
            SELECT Territory_Code__c, Territory_Manager__c, Region__c, 
                   Territory_Status__c, Regional_Manager__c, Territory_Assignment_Date__c
            FROM Account 
            WHERE Id = :testAccount.Id
        ];
        
        // Verify all assignments
        System.assertEquals('TER-CA-0001', updatedAccount.Territory_Code__c);
        System.assertEquals(territoryManager.Id, updatedAccount.Territory_Manager__c);
        System.assertEquals('NA', updatedAccount.Region__c);
        System.assertEquals(regionalManager.Id, updatedAccount.Regional_Manager__c);
        System.assertEquals('Active', updatedAccount.Territory_Status__c);
        System.assertEquals(Date.today(), updatedAccount.Territory_Assignment_Date__c);
        
        // Reset test mode
        TerritoryAssignmentService_copado.testMode = false;
        TerritoryAssignmentService_copado.testMappings.clear();
    }
    
    @isTest
    static void testAccountAssignmentWithoutRegionalManager() {
        // Get test user
        User territoryManager = [SELECT Id FROM User WHERE LastName = 'Manager NA' AND FirstName = 'Territory' LIMIT 1];
        
        // Enable test mode and inject mock mapping without regional manager
        TerritoryAssignmentService_copado.testMode = true;
        TerritoryAssignmentService_copado.testMappings.put(
            'TER-MX-0001',
            new TerritoryAssignmentService_copado.TerritoryMapping(
                territoryManager.Id,
                'NA',
                null
            )
        );
        
        Test.startTest();
        
        Account testAccount = new Account(
            Name = 'Test Account Mexico',
            Territory_Code__c = 'TER-MX-0001'
        );
        insert testAccount;
        
        Test.stopTest();
        
        // Query the account to verify assignments
        Account updatedAccount = [
            SELECT Territory_Manager__c, Region__c, Regional_Manager__c, Territory_Status__c
            FROM Account 
            WHERE Id = :testAccount.Id
        ];
        
        // Verify assignments
        System.assertEquals(territoryManager.Id, updatedAccount.Territory_Manager__c);
        System.assertEquals('NA', updatedAccount.Region__c);
        System.assertEquals(null, updatedAccount.Regional_Manager__c);
        System.assertEquals('Active', updatedAccount.Territory_Status__c);
        
        // Reset test mode
        TerritoryAssignmentService_copado.testMode = false;
        TerritoryAssignmentService_copado.testMappings.clear();
    }
    
    @isTest
    static void testAccountValidationRuleBypass() {
        // Test that validation logic works even when validation rule prevents DML
        // This tests the validateTerritoryCode method directly
        
        Test.startTest();
        
        Boolean isValid = TerritoryAssignmentService_copado.validateTerritoryCode('INVALID-CODE');
        
        Test.stopTest();
        
        System.assertEquals(false, isValid, 'Invalid code should return false');
    }
    
    @isTest
    static void testBulkAccountAssignment() {
        List<Account> accounts = new List<Account>();
        
        for (Integer i = 0; i < 200; i++) {
            String countryCode = (Math.mod(i, 4) == 0) ? 'US' : 
                                 (Math.mod(i, 4) == 1) ? 'BR' : 
                                 (Math.mod(i, 4) == 2) ? 'GB' : 'AU';
            accounts.add(new Account(
                Name = 'Bulk Test Account ' + i,
                Territory_Code__c = 'TER-' + countryCode + '-' + String.valueOf(i).leftPad(4, '0')
            ));
        }
        
        Test.startTest();
        insert accounts;
        Test.stopTest();
        
        List<Account> updatedAccounts = [
            SELECT Territory_Status__c, Region__c
            FROM Account 
            WHERE Id IN :accounts
        ];
        
        System.assertEquals(200, updatedAccounts.size(), 'All accounts should be processed');
        
        // All should have a status and region
        for (Account acc : updatedAccounts) {
            System.assertNotEquals(null, acc.Territory_Status__c, 'Status should be set');
            System.assertNotEquals(null, acc.Region__c, 'Region should be derived');
        }
    }
    
    @isTest
    static void testRegionAssignmentForAllRegions() {
        List<Account> accounts = new List<Account>();
        
        accounts.add(new Account(Name = 'NA Account', Territory_Code__c = 'TER-US-0001'));
        accounts.add(new Account(Name = 'LATAM Account', Territory_Code__c = 'TER-BR-0001'));
        accounts.add(new Account(Name = 'EMEA Account', Territory_Code__c = 'TER-GB-0001'));
        accounts.add(new Account(Name = 'APAC Account', Territory_Code__c = 'TER-AU-0001'));
        
        Test.startTest();
        insert accounts;
        Test.stopTest();
        
        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Name, Region__c 
            FROM Account 
            WHERE Id IN :accounts
        ]);
        
        for (Account acc : accounts) {
            Account updatedAcc = accountMap.get(acc.Id);
            System.assertNotEquals(null, updatedAcc.Region__c, 'Region should be assigned for ' + updatedAcc.Name);
        }
    }
    
    @isTest
    static void testClearTerritoryFieldsLogic() {
        // Test account without territory code
        Test.startTest();
        
        Account testAccount = new Account(
            Name = 'Test Account No Territory'
        );
        insert testAccount;
        
        Test.stopTest();
        
        Account updatedAccount = [
            SELECT Territory_Manager__c, Region__c, Regional_Manager__c
            FROM Account 
            WHERE Id = :testAccount.Id
        ];
        
        // All territory fields should be null
        System.assertEquals(null, updatedAccount.Territory_Manager__c);
        System.assertEquals(null, updatedAccount.Region__c);
        System.assertEquals(null, updatedAccount.Regional_Manager__c);
    }
    
    @isTest
    static void testTerritoryMappingWrapper() {
        // Test the TerritoryMapping wrapper class constructor
        User testUser1 = [SELECT Id FROM User WHERE LastName = 'Manager NA' AND FirstName = 'Territory' LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE LastName = 'Manager NA' AND FirstName = 'Regional' LIMIT 1];
        
        Test.startTest();
        
        TerritoryAssignmentService_copado.TerritoryMapping mapping = 
            new TerritoryAssignmentService_copado.TerritoryMapping(
                testUser1.Id,
                'NA',
                testUser2.Id
            );
        
        Test.stopTest();
        
        System.assertEquals(testUser1.Id, mapping.territoryManagerId, 'Territory Manager ID should match');
        System.assertEquals('NA', mapping.region, 'Region should match');
        System.assertEquals(testUser2.Id, mapping.regionalManagerId, 'Regional Manager ID should match');
    }
    
    @isTest
    static void testEmptyAccountList() {
        // Test with empty account list
        List<Account> emptyList = new List<Account>();
        
        Test.startTest();
        TerritoryAssignmentService_copado.assignTerritoryManagers(emptyList);
        Test.stopTest();
        
        // Should complete without errors
        System.assert(true, 'Empty list should be handled gracefully');
    }
    
    @isTest
    static void testAccountsWithoutTerritoryCode() {
        // Test accounts without territory codes
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'No Territory 1'));
        accounts.add(new Account(Name = 'No Territory 2'));
        
        Test.startTest();
        TerritoryAssignmentService_copado.assignTerritoryManagers(accounts);
        Test.stopTest();
        
        // Should complete without errors
        System.assert(true, 'Accounts without territory codes should be handled gracefully');
    }
}