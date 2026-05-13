@IsTest
private class AccountAutomationsTest {

    @isTest static void testDefaultDescription(){
        Account acc = new Account(Name = 'My Test Account');
        insert acc;
        acc = AccountAutomations.setDefaultDescription(acc);
        System.assertEquals('Default description', acc.Description, 'When description is null, it is updated to Default description');

        acc.Description = 'New Description Manual';
        
        acc = AccountAutomations.setDefaultDescription(acc);
        System.assertNotEquals('Default description', acc.Description, 'When description is NOT null, it is NOT updated to Default description');
    }

    @isTest static void testDefaultSite(){
        Account acc = new Account(Name = 'My Test Account');
        insert acc;
        acc = AccountAutomations.setDefaultSite(acc);
        System.assertEquals('Single location', acc.Site, 'Default Site is Single location');
    }
   //Update Changes
    //Production Deployment Updates

    @isTest static void testDefaultShippingAddress(){
        Account acc = new Account(Name = 'My Test Account');
        insert acc;
        acc = AccountAutomations.setDefaultShippingAddress(acc);
        System.assertEquals('111 W Illinois St', acc.ShippingStreet, 'Default ShippingStreet is 111 W Illinois St');
        System.assertEquals('Chicago', acc.ShippingState, 'Default Shippingtate is Chicago');
        System.assertEquals('46033', acc.ShippingPostalCode, 'Default ShippingPostalCode is 60654');
    }
    //Test Mule Commit 2.0
    @isTest static void testDefaultPhone(){
        Account acc = new Account(Name = 'My Test Account');
        insert acc;
        acc = AccountAutomations.setDefaultPhone(acc);
        System.assertEquals('318798767675', acc.Phone, 'Default phone number is 318798767675');
    }

    @isTest static void testDefaultURL(){
        Account acc = new Account(Name = 'My Test Account');
        insert acc;
        acc = AccountAutomations.setDefaultURL(acc);
        System.assertEquals('www.copado.com', acc.Website, 'Default website is www.copado.com');
    }

}