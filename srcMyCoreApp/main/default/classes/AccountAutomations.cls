public class AccountAutomations {
    private static final String DEFAULT_DESCRIPTION = 'Default description';
    private static final String DEFAULT_SITE = 'Single location';
    private static final String DEFAULT_SHIPPING_STREET = '10330 N Meridian Rd';
    private static final String DEFAULT_SHIPPING_CITY = 'Fortville';
    private static final String DEFAULT_SHIPPING_STATE = 'Indiana';
    private static final String DEFAULT_SHIPPING_POSTAL_CODE = '46040';
    private static final String DEFAULT_PHONE = '3174162277';
    private static final String DEFAULT_WEBSITE = 'www.copado.com';

    public static Account setDefaultDescription(Account accountRecord) {
        setDefaultDescription(new List<Account>{ accountRecord });
        return accountRecord;
    }

    public static List<Account> setDefaultDescription(List<Account> accounts) {
        for (Account accountRecord : safeAccounts(accounts)) {
            if (String.isBlank(accountRecord.Description)) {
                accountRecord.Description = DEFAULT_DESCRIPTION;
            }
        }
        return nullSafe(accounts);
    }

    public static Account setDefaultSite(Account accountRecord) {
        setDefaultSite(new List<Account>{ accountRecord });
        return accountRecord;
    }

    public static List<Account> setDefaultSite(List<Account> accounts) {
        for (Account accountRecord : safeAccounts(accounts)) {
            if (String.isBlank(accountRecord.Site)) {
                accountRecord.Site = DEFAULT_SITE;
            }
        }
        return nullSafe(accounts);
    }

    public static Account setDefaultShippingAddress(Account accountRecord) {
        setDefaultShippingAddress(new List<Account>{ accountRecord });
        return accountRecord;
    }

    public static List<Account> setDefaultShippingAddress(List<Account> accounts) {
        for (Account accountRecord : safeAccounts(accounts)) {
            if (String.isBlank(accountRecord.ShippingStreet)) {
                accountRecord.ShippingStreet = DEFAULT_SHIPPING_STREET;
            }
            if (String.isBlank(accountRecord.ShippingCity)) {
                accountRecord.ShippingCity = DEFAULT_SHIPPING_CITY;
            }
            if (String.isBlank(accountRecord.ShippingState)) {
                accountRecord.ShippingState = DEFAULT_SHIPPING_STATE;
            }
            if (String.isBlank(accountRecord.ShippingPostalCode)) {
                accountRecord.ShippingPostalCode = DEFAULT_SHIPPING_POSTAL_CODE;
            }
        }
        return nullSafe(accounts);
    }

    public static Account setDefaultPhone(Account accountRecord) {
        setDefaultPhone(new List<Account>{ accountRecord });
        return accountRecord;
    }

    public static List<Account> setDefaultPhone(List<Account> accounts) {
        for (Account accountRecord : safeAccounts(accounts)) {
            if (String.isBlank(accountRecord.Phone)) {
                accountRecord.Phone = DEFAULT_PHONE;
            }
        }
        return nullSafe(accounts);
    }

    public static Account setDefaultURL(Account accountRecord) {
        setDefaultURL(new List<Account>{ accountRecord });
        return accountRecord;
    }

    public static List<Account> setDefaultURL(List<Account> accounts) {
        for (Account accountRecord : safeAccounts(accounts)) {
            if (String.isBlank(accountRecord.Website)) {
                accountRecord.Website = DEFAULT_WEBSITE;
            }
        }
        return nullSafe(accounts);
    }

    public static List<Account> setDefaults(List<Account> accounts) {
        setDefaultDescription(accounts);
        setDefaultSite(accounts);
        setDefaultShippingAddress(accounts);
        setDefaultPhone(accounts);
        setDefaultURL(accounts);
        return nullSafe(accounts);
    }

    private static List<Account> safeAccounts(List<Account> accounts) {
        List<Account> safe = new List<Account>();
        if (accounts == null) {
            return safe;
        }
        for (Account accountRecord : accounts) {
            if (accountRecord != null) {
                safe.add(accountRecord);
            }
        }
        return safe;
    }

    private static List<Account> nullSafe(List<Account> accounts) {
        return accounts == null ? new List<Account>() : accounts;
    }
}