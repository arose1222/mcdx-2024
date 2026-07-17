public class AccountAutomations {

    // ---------- DESCRIPTION ----------
    public static Account setDefaultDescription(Account a) {
        setDefaultDescription(new List<Account>{ a });
        return a;
    }

    public static List<Account> setDefaultDescription(List<Account> accounts) {
        for (Account a : accounts) {
            if (a.Description == null) {
            a.Description = 'Default description';
            }
        }
        return accounts;
    }

    // ---------- SITE ----------
    public static Account setDefaultSite(Account a) {
        setDefaultSite(new List<Account>{ a });
            return a;
        }

    public static List<Account> setDefaultSite(List<Account> accounts) {
        for (Account a : accounts) {
            a.Site = 'Single location';
    }
        return accounts;
    }

    // ---------- SHIPPING ADDRESS ----------
    // Bug fix: ShippingState now correctly set to 'Indiana'; ShippingCity added for 'Fortville'.
    public static Account setDefaultShippingAddress(Account a) {
        setDefaultShippingAddress(new List<Account>{ a });
        return a;
    }

    public static List<Account> setDefaultShippingAddress(List<Account> accounts) {
        for (Account a : accounts) {
            a.ShippingStreet = '10330 N Meridian Rd';
            a.ShippingCity = 'Fortville';
            a.ShippingState = 'Indiana';
            a.ShippingPostalCode = '46040';
    }
        return accounts;
    }

    // ---------- PHONE ----------
    public static Account setDefaultPhone(Account a) {
        setDefaultPhone(new List<Account>{ a });
        return a;
    }

    public static List<Account> setDefaultPhone(List<Account> accounts) {
        for (Account a : accounts) {
            a.Phone = '3174162277';
        }
        return accounts;
    }

    // ---------- WEBSITE ----------
    public static Account setDefaultURL(Account a) {
        setDefaultURL(new List<Account>{ a });
        return a;
        //USG Updates
    }

    public static List<Account> setDefaultURL(List<Account> accounts) {
        for (Account a : accounts) {
            a.Website = 'www.copado.com';
        }
        return accounts;
    }

    // ---------- CONSOLIDATED (RECOMMENDED FOR TRIGGER HANDLERS) ----------
    // Applies all five defaults in a single pass over the collection.
    public static List<Account> setDefaults(List<Account> accounts) {
        for (Account a : accounts) {
            if (a.Description == null) {
                a.Description = 'Default description';
            }
            a.Site = 'Single location';
            a.ShippingStreet = '10330 N Meridian Rd';
            a.ShippingCity = 'Fortville';
            a.ShippingState = 'Indiana';
            a.ShippingPostalCode = '46040';
            a.Phone = '3174162277';
            a.Website = 'www.copado.com';
        }
        return accounts;
    }
}