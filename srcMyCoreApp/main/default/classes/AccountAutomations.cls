public class AccountAutomations {
    Public static Account setDefaultDescription(Account a){
        If (a.Description != null) return a;
        Else {
            a.Description = 'Default description';
            return a;
        }
    }
    //Test Mule Commit 2.0
    public static Account setDefaultSite(Account a){
        a.Site = 'Single location'; 
        return a;
    }
    //Update Changes
    //Production Deployment Updates
    public static Account setDefaultShippingAddress(Account a){
        a.shippingstreet = '111 W Illinois St'; 
        a.shippingstate = 'Chicago';
        a.shippingpostalcode ='46033';
        return a;
    }
    public static Account setDefaultPhone(Account a) {
        a.Phone='318798767675';
        return a;
    }
    public static Account setDefaultURL(Account a) {
        a.website = 'www.copado.com'; 
        return a;
    }
}