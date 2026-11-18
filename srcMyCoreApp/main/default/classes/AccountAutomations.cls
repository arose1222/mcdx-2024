/**
 * @description Utility that fills blank Account fields with standard default values.
 * Pure in-memory logic: no SOQL and no DML, so it is safe to call from before triggers
 * or flows' invocable wrappers. Callers remain responsible for persisting the records.
 */
public inherited sharing class AccountAutomations {
    @TestVisible private static final String DEFAULT_DESCRIPTION = 'Default description';
    @TestVisible private static final String DEFAULT_SITE = 'Single location';
    @TestVisible private static final String DEFAULT_SHIPPING_STREET = '10330 N Meridian Rd';
    @TestVisible private static final String DEFAULT_SHIPPING_CITY = 'Fortville';
    @TestVisible private static final String DEFAULT_SHIPPING_STATE = 'Indiana';
    @TestVisible private static final String DEFAULT_SHIPPING_POSTAL_CODE = '46040';
    @TestVisible private static final String DEFAULT_PHONE = '3174162277';
    @TestVisible private static final String DEFAULT_WEBSITE = 'www.copado.com';

    /**
     * @description Sets Description when blank.
     * @param accounts Accounts to update in memory. Null list or null entries are ignored.
     * @return The same list, or an empty list when null was supplied.
     */
    public static List<Account> setDefaultDescription(List<Account> accounts) {
        if (accounts == null) {
            return new List<Account>();
        }
        for (Account acc : accounts) {
            if (acc != null) {
                applyDescription(acc);
            }
        }
        return accounts;
    }

    /**
     * @description Sets Site when blank.
     * @param accounts Accounts to update in memory.
     * @return The same list, or an empty list when null was supplied.
     */
    public static List<Account> setDefaultSite(List<Account> accounts) {
        if (accounts == null) {
            return new List<Account>();
        }
        for (Account acc : accounts) {
            if (acc != null) {
                applySite(acc);
            }
        }
        return accounts;
    }

    /**
     * @description Fills each blank shipping address part independently.
     * @param accounts Accounts to update in memory.
     * @return The same list, or an empty list when null was supplied.
     */
    public static List<Account> setDefaultShippingAddress(List<Account> accounts) {
        if (accounts == null) {
            return new List<Account>();
        }
        for (Account acc : accounts) {
            if (acc != null) {
                applyShippingAddress(acc);
            }
        }
        return accounts;
    }

    /**
     * @description Sets Phone when blank.
     * @param accounts Accounts to update in memory.
     * @return The same list, or an empty list when null was supplied.
     */
    public static List<Account> setDefaultPhone(List<Account> accounts) {
        if (accounts == null) {
            return new List<Account>();
        }
        for (Account acc : accounts) {
            if (acc != null) {
                applyPhone(acc);
            }
        }
        return accounts;
    }

    /**
     * @description Sets Website when blank.
     * @param accounts Accounts to update in memory.
     * @return The same list, or an empty list when null was supplied.
     */
    public static List<Account> setDefaultURL(List<Account> accounts) {
        if (accounts == null) {
            return new List<Account>();
        }
        for (Account acc : accounts) {
            if (acc != null) {
                applyWebsite(acc);
            }
        }
        return accounts;
    }

    /**
     * @description Applies every default in a single pass over the list.
     * @param accounts Accounts to update in memory.
     * @return The same list, or an empty list when null was supplied.
     */
    public static List<Account> setDefaults(List<Account> accounts) {
        if (accounts == null) {
            return new List<Account>();
        }
        for (Account acc : accounts) {
            if (acc == null) {
                continue;
            }
            applyDescription(acc);
            applySite(acc);
            applyShippingAddress(acc);
            applyPhone(acc);
            applyWebsite(acc);
        }
        return accounts;
    }

    private static void applyDescription(Account acc) {
        if (String.isBlank(acc.Description)) {
            acc.Description = DEFAULT_DESCRIPTION;
        }
    }

    private static void applySite(Account acc) {
        if (String.isBlank(acc.Site)) {
            acc.Site = DEFAULT_SITE;
        }
    }

    private static void applyShippingAddress(Account acc) {
        if (String.isBlank(acc.ShippingStreet)) {
            acc.ShippingStreet = DEFAULT_SHIPPING_STREET;
        }
        if (String.isBlank(acc.ShippingCity)) {
            acc.ShippingCity = DEFAULT_SHIPPING_CITY;
        }
        if (String.isBlank(acc.ShippingState)) {
            acc.ShippingState = DEFAULT_SHIPPING_STATE;
        }
        if (String.isBlank(acc.ShippingPostalCode)) {
            acc.ShippingPostalCode = DEFAULT_SHIPPING_POSTAL_CODE;
        }
    }

    private static void applyPhone(Account acc) {
        if (String.isBlank(acc.Phone)) {
            acc.Phone = DEFAULT_PHONE;
        }
    }

    private static void applyWebsite(Account acc) {
        if (String.isBlank(acc.Website)) {
            acc.Website = DEFAULT_WEBSITE;
        }
    }
}