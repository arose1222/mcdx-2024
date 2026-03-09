/**
 * @description Trigger for automated territory assignment on Account records
 * @author Copado DevOps Demo
 * @date 2026-03-02
 */
trigger AccountTerritoryAssignment_copado on Account (before insert, before update) {
    
    // Filter accounts where Territory Code has changed
    List<Account> accountsToProcess = new List<Account>();
    
    for (Account acc : Trigger.new) {
        // For insert, process if territory code is populated
        if (Trigger.isInsert && String.isNotBlank(acc.Territory_Code__c)) {
            accountsToProcess.add(acc);
        }
        // For update, process if territory code has changed
        else if (Trigger.isUpdate) {
            Account oldAccount = Trigger.oldMap.get(acc.Id);
            if (acc.Territory_Code__c != oldAccount.Territory_Code__c) {
                accountsToProcess.add(acc);
            }
        }
    }
    
    // Delegate to service class
    if (!accountsToProcess.isEmpty()) {
        TerritoryAssignmentService_copado.assignTerritoryManagers(accountsToProcess);
    }
}