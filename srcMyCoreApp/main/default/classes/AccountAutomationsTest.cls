@IsTest
private class AccountAutomationsTest {

    private static List<Account> buildAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(Name = 'Bulk Test Account ' + i));
        }
        return accounts;
    }

    // ---------- EXISTING SINGLE-RECORD TESTS (RETAINED) ----------

    @isTest static void testDefaultDescription() {
        Account acc = new Account(Name = 'My Test Account');
        insert acc;
        acc = AccountAutomations.setDefaultDescription(acc);
        System.assertEquals('Default description', acc.Description, 'When description is null, it is updated to Default description');

        acc.Description = 'New Description Manual';
        acc = AccountAutomations.setDefaultDescription(acc);
        System.assertNotEquals('Default description', acc.Description, 'When description is NOT null, it is NOT updated to Default description');
    }

    @isTest static void testDefaultSite() {
        Account acc = new Account(Name = 'My Test Account');
        insert acc;
        acc = AccountAutomations.setDefaultSite(acc);
        System.assertEquals('Single location', acc.Site, 'Default Site is Single location');
    }

    @isTest static void testDefaultShippingAddress() {
        Account acc = new Account(Name = 'My Test Account');
        insert acc;
        acc = AccountAutomations.setDefaultShippingAddress(acc);
        System.assertEquals('10330 N Meridian Rd', acc.ShippingStreet, 'Default ShippingStreet is 10330 N Meridian Rd');
        System.assertEquals('Fortville', acc.ShippingCity, 'Default ShippingCity is Fortville');
        System.assertEquals('Indiana', acc.ShippingState, 'Default ShippingState is Indiana');
        System.assertEquals('46040', acc.ShippingPostalCode, 'Default ShippingPostalCode is 46040');
    }

    @isTest static void testDefaultPhone() {
        Account acc = new Account(Name = 'My Test Account');
        insert acc;
        acc = AccountAutomations.setDefaultPhone(acc);
        System.assertEquals('3174162277', acc.Phone, 'Default phone number is 3174162277');
    }

    @isTest static void testDefaultURL() {
        Account acc = new Account(Name = 'My Test Account');
        insert acc;
        acc = AccountAutomations.setDefaultURL(acc);
        System.assertEquals('www.copado.com', acc.Website, 'Default website is www.copado.com');
    }

    // ---------- NEW BULK TESTS ----------

    @isTest static void testBulkDefaultDescription() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].Description = 'Pre-set description';

        Test.startTest();
        AccountAutomations.setDefaultDescription(accounts);
        Test.stopTest();

        System.assertEquals('Pre-set description', accounts[0].Description, 'Existing description should not be overwritten');
        for (Integer i = 1; i < accounts.size(); i++) {
            System.assertEquals('Default description', accounts[i].Description, 'Blank description should default for record ' + i);
        }
    }

    @isTest static void testBulkDefaultSite() {
        List<Account> accounts = buildAccounts(200);

        Test.startTest();
        AccountAutomations.setDefaultSite(accounts);
        Test.stopTest();

        for (Account a : accounts) {
            System.assertEquals('Single location', a.Site, 'Default Site should apply across the bulk set');
        }
    }

    @isTest static void testBulkDefaultShippingAddress() {
        List<Account> accounts = buildAccounts(200);

        Test.startTest();
        AccountAutomations.setDefaultShippingAddress(accounts);
        Test.stopTest();

        for (Account a : accounts) {
            System.assertEquals('10330 N Meridian Rd', a.ShippingStreet, 'ShippingStreet should apply across the bulk set');
            System.assertEquals('Fortville', a.ShippingCity, 'ShippingCity should apply across the bulk set');
            System.assertEquals('Indiana', a.ShippingState, 'ShippingState should apply across the bulk set');
            System.assertEquals('46040', a.ShippingPostalCode, 'ShippingPostalCode should apply across the bulk set');
        }
    }

    @isTest static void testBulkDefaultPhone() {
        List<Account> accounts = buildAccounts(200);

        Test.startTest();
        AccountAutomations.setDefaultPhone(accounts);
        Test.stopTest();

        for (Account a : accounts) {
            System.assertEquals('3174162277', a.Phone, 'Default phone should apply across the bulk set');
        }
    }

    @isTest static void testBulkDefaultURL() {
        List<Account> accounts = buildAccounts(200);

        Test.startTest();
        AccountAutomations.setDefaultURL(accounts);
        Test.stopTest();

        for (Account a : accounts) {
            System.assertEquals('www.copado.com', a.Website, 'Default website should apply across the bulk set');
        }
    }

    @isTest static void testBulkSetDefaultsConsolidated() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].Description = 'Manually entered description';

        Test.startTest();
        AccountAutomations.setDefaults(accounts);
        insert accounts;
        Test.stopTest();

        List<Account> inserted = [
            SELECT Description, Site, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Phone, Website
            FROM Account
            WHERE Id IN :accounts
        ];

        System.assertEquals(200, inserted.size(), 'All 200 bulk accounts should insert successfully');

        for (Account a : inserted) {
            System.assertEquals('Single location', a.Site, 'Site default should apply');
            System.assertEquals('10330 N Meridian Rd', a.ShippingStreet, 'ShippingStreet default should apply');
            System.assertEquals('Fortville', a.ShippingCity, 'ShippingCity default should apply');
            System.assertEquals('Indiana', a.ShippingState, 'ShippingState default should apply');
            System.assertEquals('46040', a.ShippingPostalCode, 'ShippingPostalCode default should apply');
            System.assertEquals('3174162277', a.Phone, 'Phone default should apply');
            System.assertEquals('www.copado.com', a.Website, 'Website default should apply');
        }
    }
}