/**
 * @description Applies an in-memory default description when Description is blank.
 * Does not query or save records.
 */
public with sharing class AccountOperations {
  private static final String DEFAULT_DESCRIPTION = 'Default description';

  /**
   * @description Sets Description to the default text when it is null or whitespace.
   * A non-blank description is left unchanged. Delegates to the list method.
   * @param accountRecord Record updated in memory
   * @return The same instance, or null when the argument is null
   */
  public static Account setDefaultDescription(Account accountRecord) {
    List<Account> updatedRecords = setDefaultDescription(
      accountRecord == null ? null : new List<Account>{ accountRecord }
    );
    return updatedRecords.isEmpty() ? null : updatedRecords[0];
  }

  /**
   * @description Sets Description to the default text when it is null or whitespace.
   * Null entries are skipped. A null list returns a new empty list.
   * @param accountRecords Records updated in memory
   * @return The same list, or an empty list when the argument is null
   */
  public static List<Account> setDefaultDescription(List<Account> accountRecords) {
    if (accountRecords == null) {
      return new List<Account>();
    }
    for (Account accountRecord : accountRecords) {
      if (accountRecord == null || !String.isBlank(accountRecord.Description)) {
        continue;
      }
      accountRecord.Description = DEFAULT_DESCRIPTION;
    }
    return accountRecords;
  }
}
