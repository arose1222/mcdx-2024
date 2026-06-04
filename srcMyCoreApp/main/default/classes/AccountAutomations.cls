public class AccountAutomations {
    Public static Account setDefaultDescription(Account a){
        If (a.Description != null) return a;
        Else {
            a.Description = 'Default description';
            return a;
        }
    }
    public static Account setDefaultSite(Account a){
        a.Site = 'Single location'; 
        return a;
    }
    //Merge Conflict
    public static Account setDefaultShippingAddress(Account a){
        a.shippingstreet = '10330 N Meridian Rd'; 
        a.shippingstate = 'Fortville';
        a.shippingpostalcode ='46040';
        return a;
    }
    public static Account setDefaultPhone(Account a) {
        a.Phone='3174162277';
        return a;
    }
    public static Account setDefaultURL(Account a) {
        a.website = 'www.copa.do'; 
        return a;
        //USG Updates
    }
}