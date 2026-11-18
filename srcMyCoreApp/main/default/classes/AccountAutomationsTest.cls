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
        Assert.areEqual(0, Limits.getQueries(), 'Defaulting should not query');
        Assert.areEqual(0, Limits.getDmlStatements(), 'Defaulting should not perform DML');
    }

    // ---------- Description ----------

    @IsTest
    static void testDefaultDescriptionWhenBlank() {
        Account acc = new Account(Name = 'My Test Account');

        AccountAutomations.setDefaultDescription(new List<Account>{ acc });

        Assert.areEqual(AccountAutomations.DEFAULT_DESCRIPTION, acc.Description);
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testDefaultDescriptionWhenWhitespace() {
        Account acc = new Account(Name = 'My Test Account', Description = '   ');

        AccountAutomations.setDefaultDescription(new List<Account>{ acc });

        Assert.areEqual(AccountAutomations.DEFAULT_DESCRIPTION, acc.Description);
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testDefaultDescriptionPreservesExisting() {
        Account acc = new Account(Name = 'My Test Account', Description = 'New Description Manual');

        AccountAutomations.setDefaultDescription(new List<Account>{ acc });

        Assert.areEqual('New Description Manual', acc.Description);
        assertNoQueriesOrDml();
    }

    // ---------- Site ----------

    @IsTest
    static void testDefaultSite() {
        Account acc = new Account(Name = 'My Test Account');

        AccountAutomations.setDefaultSite(new List<Account>{ acc });

        Assert.areEqual(AccountAutomations.DEFAULT_SITE, acc.Site);
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testDefaultSitePreservesExisting() {
        Account acc = new Account(Name = 'My Test Account', Site = 'Headquarters');

        AccountAutomations.setDefaultSite(new List<Account>{ acc });

        Assert.areEqual('Headquarters', acc.Site);
        assertNoQueriesOrDml();
    }

    // ---------- Shipping address ----------

    @IsTest
    static void testDefaultShippingAddress() {
        Account acc = new Account(Name = 'My Test Account');

        AccountAutomations.setDefaultShippingAddress(new List<Account>{ acc });

        Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_STREET, acc.ShippingStreet);
        Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_CITY, acc.ShippingCity);
        Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_STATE, acc.ShippingState);
        Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_POSTAL_CODE, acc.ShippingPostalCode);
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testShippingAddressFillsOnlyBlankParts() {
        Account acc = new Account(
            Name = 'My Test Account',
            ShippingStreet = '1 Main St',
            ShippingState = 'Ohio'
        );

        AccountAutomations.setDefaultShippingAddress(new List<Account>{ acc });

        Assert.areEqual('1 Main St', acc.ShippingStreet);
        Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_CITY, acc.ShippingCity);
        Assert.areEqual('Ohio', acc.ShippingState);
        Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_POSTAL_CODE, acc.ShippingPostalCode);
        assertNoQueriesOrDml();
    }

    // ---------- Phone ----------

    @IsTest
    static void testDefaultPhone() {
        Account acc = new Account(Name = 'My Test Account');

        AccountAutomations.setDefaultPhone(new List<Account>{ acc });

        Assert.areEqual(AccountAutomations.DEFAULT_PHONE, acc.Phone);
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testDefaultPhonePreservesExisting() {
        Account acc = new Account(Name = 'My Test Account', Phone = '3175550100');

        AccountAutomations.setDefaultPhone(new List<Account>{ acc });

        Assert.areEqual('3175550100', acc.Phone);
        assertNoQueriesOrDml();
    }

    // ---------- Website ----------

    @IsTest
    static void testDefaultURL() {
        Account acc = new Account(Name = 'My Test Account');

        AccountAutomations.setDefaultURL(new List<Account>{ acc });

        Assert.areEqual(AccountAutomations.DEFAULT_WEBSITE, acc.Website);
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testDefaultURLPreservesExisting() {
        Account acc = new Account(Name = 'My Test Account', Website = 'www.example.com');

        AccountAutomations.setDefaultURL(new List<Account>{ acc });

        Assert.areEqual('www.example.com', acc.Website);
        assertNoQueriesOrDml();
    }

    // ---------- Null and edge handling ----------

    @IsTest
    static void testNullListReturnsEmptyList() {
        Assert.areEqual(0, AccountAutomations.setDefaultDescription(null).size());
        Assert.areEqual(0, AccountAutomations.setDefaultSite(null).size());
        Assert.areEqual(0, AccountAutomations.setDefaultShippingAddress(null).size());
        Assert.areEqual(0, AccountAutomations.setDefaultPhone(null).size());
        Assert.areEqual(0, AccountAutomations.setDefaultURL(null).size());
        Assert.areEqual(0, AccountAutomations.setDefaults(null).size());
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testEmptyListReturnsEmptyList() {
        Assert.areEqual(0, AccountAutomations.setDefaults(new List<Account>()).size());
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testNullAccountIsSkippedByEveryMethod() {
        List<Account> accounts = new List<Account>{ null, new Account(Name = 'Kept') };

        AccountAutomations.setDefaultDescription(accounts);
        AccountAutomations.setDefaultSite(accounts);
        AccountAutomations.setDefaultShippingAddress(accounts);
        AccountAutomations.setDefaultPhone(accounts);
        AccountAutomations.setDefaultURL(accounts);
        AccountAutomations.setDefaults(accounts);

        Assert.areEqual(2, accounts.size());
        Assert.isNull(accounts[0]);
        Assert.areEqual(AccountAutomations.DEFAULT_DESCRIPTION, accounts[1].Description);
        Assert.areEqual(AccountAutomations.DEFAULT_SITE, accounts[1].Site);
        Assert.areEqual(AccountAutomations.DEFAULT_PHONE, accounts[1].Phone);
        Assert.areEqual(AccountAutomations.DEFAULT_WEBSITE, accounts[1].Website);
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testReturnsSameListInstanceContents() {
        List<Account> accounts = buildAccounts(3);

        List<Account> result = AccountAutomations.setDefaults(accounts);

        Assert.areEqual(3, result.size());
        Assert.areEqual(AccountAutomations.DEFAULT_DESCRIPTION, result[2].Description);
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testSetDefaultsMatchesIndividualSetters() {
        Account viaDefaults = new Account(Name = 'Parity A', Phone = '3175550100', Description = '   ');
        Account viaSetters = new Account(Name = 'Parity B', Phone = '3175550100', Description = '   ');
        List<Account> setterList = new List<Account>{ viaSetters };

        AccountAutomations.setDefaults(new List<Account>{ viaDefaults });
        AccountAutomations.setDefaultDescription(setterList);
        AccountAutomations.setDefaultSite(setterList);
        AccountAutomations.setDefaultShippingAddress(setterList);
        AccountAutomations.setDefaultPhone(setterList);
        AccountAutomations.setDefaultURL(setterList);

        Assert.areEqual(viaSetters.Description, viaDefaults.Description);
        Assert.areEqual(viaSetters.Site, viaDefaults.Site);
        Assert.areEqual(viaSetters.ShippingStreet, viaDefaults.ShippingStreet);
        Assert.areEqual(viaSetters.ShippingCity, viaDefaults.ShippingCity);
        Assert.areEqual(viaSetters.ShippingState, viaDefaults.ShippingState);
        Assert.areEqual(viaSetters.ShippingPostalCode, viaDefaults.ShippingPostalCode);
        Assert.areEqual(viaSetters.Phone, viaDefaults.Phone);
        Assert.areEqual(viaSetters.Website, viaDefaults.Website);
        Assert.areEqual('3175550100', viaDefaults.Phone);
        Assert.areEqual(AccountAutomations.DEFAULT_DESCRIPTION, viaDefaults.Description);
        assertNoQueriesOrDml();
    }

    // ---------- Bulk ----------

    @IsTest
    static void testBulkDefaultDescription() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].Description = 'Pre-set description';
        accounts[1].Description = '  ';

        AccountAutomations.setDefaultDescription(accounts);

        Assert.areEqual('Pre-set description', accounts[0].Description);
        Assert.areEqual(AccountAutomations.DEFAULT_DESCRIPTION, accounts[1].Description);
        for (Integer i = 2; i < accounts.size(); i++) {
            Assert.areEqual(AccountAutomations.DEFAULT_DESCRIPTION, accounts[i].Description, 'Blank description should default for record ' + i);
        }
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testBulkDefaultSite() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].Site = 'Headquarters';

        AccountAutomations.setDefaultSite(accounts);

        Assert.areEqual('Headquarters', accounts[0].Site);
        for (Integer i = 1; i < accounts.size(); i++) {
            Assert.areEqual(AccountAutomations.DEFAULT_SITE, accounts[i].Site);
        }
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testBulkDefaultShippingAddress() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].ShippingStreet = '1 Main St';

        AccountAutomations.setDefaultShippingAddress(accounts);

        Assert.areEqual('1 Main St', accounts[0].ShippingStreet);
        Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_CITY, accounts[0].ShippingCity);
        for (Integer i = 1; i < accounts.size(); i++) {
            Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_STREET, accounts[i].ShippingStreet);
            Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_CITY, accounts[i].ShippingCity);
            Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_STATE, accounts[i].ShippingState);
            Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_POSTAL_CODE, accounts[i].ShippingPostalCode);
        }
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testBulkDefaultPhone() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].Phone = '3175550100';

        AccountAutomations.setDefaultPhone(accounts);

        Assert.areEqual('3175550100', accounts[0].Phone);
        for (Integer i = 1; i < accounts.size(); i++) {
            Assert.areEqual(AccountAutomations.DEFAULT_PHONE, accounts[i].Phone);
        }
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testBulkDefaultURL() {
        List<Account> accounts = buildAccounts(200);
        accounts[0].Website = 'www.example.com';

        AccountAutomations.setDefaultURL(accounts);

        Assert.areEqual('www.example.com', accounts[0].Website);
        for (Integer i = 1; i < accounts.size(); i++) {
            Assert.areEqual(AccountAutomations.DEFAULT_WEBSITE, accounts[i].Website);
        }
        assertNoQueriesOrDml();
    }

    @IsTest
    static void testBulkSetDefaultsConsolidated() {
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

        Assert.areEqual(200, inserted.size(), 'All 200 bulk accounts should insert successfully');

        Account preserved;
        Account defaulted;
        for (Account insertedAccount : inserted) {
            if (insertedAccount.Name == 'Bulk Test Account 0') {
                preserved = insertedAccount;
            } else if (insertedAccount.Name == 'Bulk Test Account 1') {
                defaulted = insertedAccount;
            }
        }

        Assert.areEqual('Manually entered description', preserved.Description);
        Assert.areEqual('Headquarters', preserved.Site);
        Assert.areEqual('1 Main St', preserved.ShippingStreet);
        Assert.areEqual('Columbus', preserved.ShippingCity);
        Assert.areEqual('Ohio', preserved.ShippingState);
        Assert.areEqual('43004', preserved.ShippingPostalCode);
        Assert.areEqual('3175550100', preserved.Phone);
        Assert.areEqual('www.example.com', preserved.Website);

        Assert.areEqual(AccountAutomations.DEFAULT_DESCRIPTION, defaulted.Description);
        Assert.areEqual(AccountAutomations.DEFAULT_SITE, defaulted.Site);
        Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_STREET, defaulted.ShippingStreet);
        Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_CITY, defaulted.ShippingCity);
        Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_STATE, defaulted.ShippingState);
        Assert.areEqual(AccountAutomations.DEFAULT_SHIPPING_POSTAL_CODE, defaulted.ShippingPostalCode);
        Assert.areEqual(AccountAutomations.DEFAULT_PHONE, defaulted.Phone);
        Assert.areEqual(AccountAutomations.DEFAULT_WEBSITE, defaulted.Website);
    }
}