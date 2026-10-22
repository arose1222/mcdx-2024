@IsTest
private class AccountAutomationsTest {
    private static List<Account> buildAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(new Account(Name = 'Bulk Test Account ' + i));
        }
        return accounts;
    }

    private static void assertNoQueriesOrDml() {
        System.assertEquals(0, Limits.getQueries(), 'Defaulting should not query');
        System.assertEquals(0, Limits.getDmlStatements(), 'Defaulting should not perform DML');
    }

    @isTest static void testDefaultDescriptionWhenBlank() {
        Account acc = new Account(Name = 'My Test Account');

        acc = AccountAutomations.setDefaultDescription(acc);

        System.assertEquals('Default description', acc.Description);
        assertNoQueriesOrDml();
    }

    @isTest static void testDefaultDescriptionWhenWhitespace() {
        Account acc = new Account(Name = 'My Test Account', Description = '   ');

        acc = AccountAutomations.setDefaultDescription(acc);

        System.assertEquals('Default description', acc.Description);
        assertNoQueriesOrDml();
    }

    @isTest static void testDefaultDescriptionPreservesExisting() {
        Account acc = new Account(Name = 'My Test Account', Description = 'New Description Manual');

        acc = AccountAutomations.setDefaultDescription(acc);

        System.assertEquals('New Description Manual', acc.Description);
        assertNoQueriesOrDml();
    }

    @isTest static void testDefaultSite() {
        Account acc = new Account(Name = 'My Test Account');

        acc = AccountAutomations.setDefaultSite(acc);

        System.assertEquals('Single location', acc.Site);
        assertNoQueriesOrDml();
    }

    @isTest static void testDefaultSitePreservesExisting() {
        Account acc = new Account(Name = 'My Test Account', Site = 'Headquarters');

        acc = AccountAutomations.setDefaultSite(acc);

        System.assertEquals('Headquarters', acc.Site);
        assertNoQueriesOrDml();
    }

    @isTest static void testDefaultShippingAddress() {
        Account acc = new Account(Name = 'My Test Account');

        acc = AccountAutomations.setDefaultShippingAddress(acc);

        System.assertEquals('10330 N Meridian Rd', acc.ShippingStreet);
        System.assertEquals('Fortville', acc.ShippingCity);
        System.assertEquals('Indiana', acc.ShippingState);
        System.assertEquals('46040', acc.ShippingPostalCode);
        assertNoQueriesOrDml();
    }

    @isTest static void testShippingAddressFillsOnlyBlankParts() {
        Account acc = new Account(
            Name = 'My Test Account',
            ShippingStreet = '1 Main St',
            ShippingState = 'Ohio'
        );

        acc = AccountAutomations.setDefaultShippingAddress(acc);

        System.assertEquals('1 Main St', acc.ShippingStreet);
        System.assertEquals('Fortville', acc.ShippingCity);
        System.assertEquals('Ohio', acc.ShippingState);
        System.assertEquals('46040', acc.ShippingPostalCode);
        assertNoQueriesOrDml();
    }

    @isTest static void testDefaultPhone() {
        Account acc = new Account(Name = 'My Test Account');

        acc = AccountAutomations.setDefaultPhone(acc);

        System.assertEquals('3174162277', acc.Phone);
        assertNoQueriesOrDml();
    }

    @isTest static void testDefaultPhonePreservesExisting() {
        Account acc = new Account(Name = 'My Test Account', Phone = '3175550100');

        acc = AccountAutomations.setDefaultPhone(acc);

        System.assertEquals('3175550100', acc.Phone);
        assertNoQueriesOrDml();
    }

    @isTest static void testDefaultURL() {
        Account acc = new Account(Name = 'My Test Account');

        acc = AccountAutomations.setDefaultURL(acc);

        System.assertEquals('www.copado.com', acc.Website);
        assertNoQueriesOrDml();
    }

    @isTest static void testDefaultURLPreservesExisting() {
        Account acc = new Account(Name = 'My Test Account', Website = 'www.example.com');

        acc = AccountAutomations.setDefaultURL(acc);

        System.assertEquals('www.example.com', acc.Website);
        assertNoQueriesOrDml();
    }

    @isTest static void testNullListReturnsEmptyList() {
        System.assertEquals(0, AccountAutomations.setDefaultDescription((List<Account>) null).size());
        System.assertEquals(0, AccountAutomations.setDefaultSite((List<Account>) null).size());
        System.assertEquals(0, AccountAutomations.setDefaultShippingAddress((List<Account>) null).size());
        System.assertEquals(0, AccountAutomations.setDefaultPhone((List<Account>) null).size());
        System.assertEquals(0, AccountAutomations.setDefaultURL((List<Account>) null).size());
        System.assertEquals(0, AccountAutomations.setDefaults((List<Account>) null).size());
        assertNoQueriesOrDml();
    }

    @isTest static void testNullAccountIsSkipped() {
        List<Account> accounts = new List<Account>{ null, new Account(Name = 'Kept') };

        AccountAutomations.setDefaults(accounts);

        System.assertEquals(2, accounts.size());
        System.assertEquals(null, accounts[0]);
        System.assertEquals('Default description', accounts[1].Description);
        System.assertEquals('Single location', accounts[1].Site);
        System.assertEquals('3174162277', accounts[1].Phone);
        System.assertEquals('www.copado.com', accounts[1].Website);
        assertNoQueriesOrDml();
    }

    @isTest static void testSetDefaultsMatchesIndividualSetters() {
        Account viaDefaults = new Account(Name = 'Parity A', Phone = '3175550100', Description = '   ');
        Account viaSetters = new Account(Name = 'Parity B', Phone = '3175550100', Description = '   ');

        AccountAutomations.setDefaults(new List<Account>{ viaDefaults });
        AccountAutomations.setDefaultDescription(viaSetters);
        AccountAutomations.setDefaultSite(viaSetters);
        AccountAutomations.setDefaultShippingAddress(viaSetters);
        AccountAutomations.setDefaultPhone(viaSetters);
        AccountAutomations.setDefaultURL(viaSetters);

        System.assertEquals(viaSetters.Description, viaDefaults.Description);
        System.assertEquals(viaSetters.Site, viaDefaults.Site);
        System.assertEquals(viaSetters.ShippingStreet, viaDefaults.ShippingStreet);
        System.assertEquals(viaSetters.ShippingCity, viaDefaults.ShippingCity);
        System.assertEquals(viaSetters.ShippingState, viaDefaults.ShippingState);
        System.assertEquals(viaSetters.ShippingPostalCode, viaDefaults.ShippingPostalCode);
        System.assertEquals(viaSetters.Phone, viaDefaults.Phone);
        System.assertEquals(viaSetters.Website, viaDefaults.Website);
        System.assertEquals('3175550100', viaDefaults.Phone);
        System.assertEquals('Default description', viaDefaults.Description);
        assertNoQueriesOrDml();
    }

    @isTest static void testBulkDefaultDescription() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].Description = 'Pre-set description';
        accounts[1].Description = '  ';

        AccountAutomations.setDefaultDescription(accounts);

        System.assertEquals('Pre-set description', accounts[0].Description);
        System.assertEquals('Default description', accounts[1].Description);
        for (Integer i = 2; i < accounts.size(); i++) {
            System.assertEquals('Default description', accounts[i].Description, 'Blank description should default for record ' + i);
        }
        assertNoQueriesOrDml();
    }

    @isTest static void testBulkDefaultSite() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].Site = 'Headquarters';

        AccountAutomations.setDefaultSite(accounts);

        System.assertEquals('Headquarters', accounts[0].Site);
        for (Integer i = 1; i < accounts.size(); i++) {
            System.assertEquals('Single location', accounts[i].Site);
        }
        assertNoQueriesOrDml();
    }

    @isTest static void testBulkDefaultShippingAddress() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].ShippingStreet = '1 Main St';

        AccountAutomations.setDefaultShippingAddress(accounts);

        System.assertEquals('1 Main St', accounts[0].ShippingStreet);
        System.assertEquals('Fortville', accounts[0].ShippingCity);
        for (Integer i = 1; i < accounts.size(); i++) {
            System.assertEquals('10330 N Meridian Rd', accounts[i].ShippingStreet);
            System.assertEquals('Fortville', accounts[i].ShippingCity);
            System.assertEquals('Indiana', accounts[i].ShippingState);
            System.assertEquals('46040', accounts[i].ShippingPostalCode);
        }
        assertNoQueriesOrDml();
    }

    @isTest static void testBulkDefaultPhone() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].Phone = '3175550100';

        AccountAutomations.setDefaultPhone(accounts);

        System.assertEquals('3175550100', accounts[0].Phone);
        for (Integer i = 1; i < accounts.size(); i++) {
            System.assertEquals('3174162277', accounts[i].Phone);
        }
        assertNoQueriesOrDml();
    }

    @isTest static void testBulkDefaultURL() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].Website = 'www.example.com';

        AccountAutomations.setDefaultURL(accounts);

        System.assertEquals('www.example.com', accounts[0].Website);
        for (Integer i = 1; i < accounts.size(); i++) {
            System.assertEquals('www.copado.com', accounts[i].Website);
        }
        assertNoQueriesOrDml();
    }

    @isTest static void testBulkSetDefaultsConsolidated() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].Description = 'Manually entered description';
        accounts[0].Site = 'Headquarters';
        accounts[0].ShippingStreet = '1 Main St';
        accounts[0].ShippingCity = 'Columbus';
        accounts[0].ShippingState = 'Ohio';
        accounts[0].ShippingPostalCode = '43004';
        accounts[0].Phone = '3175550100';
        accounts[0].Website = 'www.example.com';

        Test.startTest();
        AccountAutomations.setDefaults(accounts);
        insert accounts;
        Test.stopTest();

        List<Account> inserted = [
            SELECT Name, Description, Site, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Phone, Website
            FROM Account
            WHERE Id IN :accounts
        ];

        System.assertEquals(200, inserted.size(), 'All 200 bulk accounts should insert successfully');

        Account preserved;
        Account defaulted;
        for (Account insertedAccount : inserted) {
            if (insertedAccount.Name == 'Bulk Test Account 0') {
                preserved = insertedAccount;
            } else if (insertedAccount.Name == 'Bulk Test Account 1') {
                defaulted = insertedAccount;
            }
        }

        System.assertEquals('Manually entered description', preserved.Description);
        System.assertEquals('Headquarters', preserved.Site);
        System.assertEquals('1 Main St', preserved.ShippingStreet);
        System.assertEquals('Columbus', preserved.ShippingCity);
        System.assertEquals('Ohio', preserved.ShippingState);
        System.assertEquals('43004', preserved.ShippingPostalCode);
        System.assertEquals('3175550100', preserved.Phone);
        System.assertEquals('www.example.com', preserved.Website);

        System.assertEquals('Default description', defaulted.Description);
        System.assertEquals('Single location', defaulted.Site);
        System.assertEquals('10330 N Meridian Rd', defaulted.ShippingStreet);
        System.assertEquals('Fortville', defaulted.ShippingCity);
        System.assertEquals('Indiana', defaulted.ShippingState);
        System.assertEquals('46040', defaulted.ShippingPostalCode);
        System.assertEquals('3174162277', defaulted.Phone);
        System.assertEquals('www.copado.com', defaulted.Website);
    }
}