/**
 * @description Applies an in-memory default description.
 */
public class AccountOperations {
  private static final String DEFAULT_DESCRIPTION = 'Default description';

  /**
   * @description Sets Description to the default text in memory.
   * Null input is returned as null. Non-null input is updated and returned as the same instance.
   * @param accountRecord Record updated in memory
   * @return The same instance, or null when the argument is null
   */
  public static Account setDefaultDescription(Account accountRecord) {
    if (accountRecord == null) {
      return null;
    }
    accountRecord.Description = DEFAULT_DESCRIPTION;
    return accountRecord;
  }
}
