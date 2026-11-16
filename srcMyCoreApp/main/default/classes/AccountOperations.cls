public class AccountOperations {
    private static final String DEFAULT_DESCRIPTION = 'Default description';

    public static Account setDefaultDescription(Account a) {
        if (a == null) {
            return null;
        }
        setDefaultDescription(new List<Account>{ a });
        return a;
    }

    public static List<Account> setDefaultDescription(List<Account> accounts) {
        if (accounts == null) {
            return new List<Account>();
        }
        for (Account a : accounts) {
            if (a != null && String.isBlank(a.Description)) {
                a.Description = DEFAULT_DESCRIPTION;
            }
        }
        return accounts;
    }
}