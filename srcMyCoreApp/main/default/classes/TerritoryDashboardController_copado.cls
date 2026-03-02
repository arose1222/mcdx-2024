/**
 * @description Controller for Territory Dashboard Lightning Web Component
 * @author Copado DevOps Demo
 * @date 2026-03-02
 */
public with sharing class TerritoryDashboardController_copado {
    
    /**
     * @description Wrapper class for territory statistics
     */
    public class TerritoryStats {
        @AuraEnabled public Integer totalAccounts { get; set; }
        @AuraEnabled public Integer activeAccounts { get; set; }
        @AuraEnabled public Integer pendingAccounts { get; set; }
        @AuraEnabled public Integer draftAccounts { get; set; }
        @AuraEnabled public Integer inactiveAccounts { get; set; }
        @AuraEnabled public List<TerritoryData> territories { get; set; }
        
        public TerritoryStats() {
            this.totalAccounts = 0;
            this.activeAccounts = 0;
            this.pendingAccounts = 0;
            this.draftAccounts = 0;
            this.inactiveAccounts = 0;
            this.territories = new List<TerritoryData>();
        }
    }
    
    /**
     * @description Wrapper class for individual territory data
     */
    public class TerritoryData {
        @AuraEnabled public String territoryCode { get; set; }
        @AuraEnabled public String managerName { get; set; }
        @AuraEnabled public String managerId { get; set; }
        @AuraEnabled public Integer accountCount { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Date lastAssignmentDate { get; set; }
    }
    
    /**
     * @description Retrieves territory statistics and account data
     * @return TerritoryStats object containing all territory information
     */
    @AuraEnabled(cacheable=true)
    public static TerritoryStats getTerritoryStatistics() {
        try {
            TerritoryStats stats = new TerritoryStats();
            
            // Query all accounts with territory information
            List<Account> accounts = [
                SELECT Id, Name, Territory_Code__c, Territory_Manager__c, 
                       Territory_Manager__r.Name, Territory_Status__c, 
                       Territory_Assignment_Date__c
                FROM Account
                WHERE Territory_Code__c != null
                ORDER BY Territory_Code__c
            ];
            
            stats.totalAccounts = accounts.size();
            
            // Group accounts by territory code
            Map<String, List<Account>> accountsByTerritory = new Map<String, List<Account>>();
            
            for (Account acc : accounts) {
                // Count by status
                if (acc.Territory_Status__c == 'Active') {
                    stats.activeAccounts++;
                } else if (acc.Territory_Status__c == 'Pending Review') {
                    stats.pendingAccounts++;
                } else if (acc.Territory_Status__c == 'Draft') {
                    stats.draftAccounts++;
                } else if (acc.Territory_Status__c == 'Inactive') {
                    stats.inactiveAccounts++;
                }
                
                // Group by territory
                if (!accountsByTerritory.containsKey(acc.Territory_Code__c)) {
                    accountsByTerritory.put(acc.Territory_Code__c, new List<Account>());
                }
                accountsByTerritory.get(acc.Territory_Code__c).add(acc);
            }
            
            // Build territory data
            for (String territoryCode : accountsByTerritory.keySet()) {
                List<Account> territoryAccounts = accountsByTerritory.get(territoryCode);
                Account firstAccount = territoryAccounts[0];
                
                TerritoryData territory = new TerritoryData();
                territory.territoryCode = territoryCode;
                territory.accountCount = territoryAccounts.size();
                territory.managerId = firstAccount.Territory_Manager__c;
                territory.managerName = firstAccount.Territory_Manager__r?.Name;
                territory.status = firstAccount.Territory_Status__c;
                territory.lastAssignmentDate = firstAccount.Territory_Assignment_Date__c;
                
                stats.territories.add(territory);
            }
            
            return stats;
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in getTerritoryStatistics: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error retrieving territory statistics: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves accounts for a specific territory
     * @param territoryCode The territory code to filter by
     * @return List of Account records
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsByTerritory(String territoryCode) {
        try {
            return [
                SELECT Id, Name, Territory_Code__c, Territory_Manager__c,
                       Territory_Manager__r.Name, Territory_Status__c,
                       Territory_Assignment_Date__c, Industry, AnnualRevenue
                FROM Account
                WHERE Territory_Code__c = :territoryCode
                ORDER BY Name
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in getAccountsByTerritory: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving accounts: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves accounts by status
     * @param status The territory status to filter by
     * @return List of Account records
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsByStatus(String status) {
        try {
            return [
                SELECT Id, Name, Territory_Code__c, Territory_Manager__c,
                       Territory_Manager__r.Name, Territory_Status__c,
                       Territory_Assignment_Date__c
                FROM Account
                WHERE Territory_Status__c = :status
                ORDER BY Territory_Code__c, Name
                LIMIT 1000
            ];
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in getAccountsByStatus: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving accounts by status: ' + e.getMessage());
        }
    }
    
    /**
     * @description Reassigns accounts to a new territory manager
     * @param accountIds List of Account IDs to reassign
     * @param newManagerId User ID of the new territory manager
     * @return Number of accounts successfully reassigned
     */
    @AuraEnabled
    public static Integer reassignAccounts(List<Id> accountIds, Id newManagerId) {
        try {
            List<Account> accountsToUpdate = [
                SELECT Id, Territory_Manager__c, Territory_Assignment_Date__c, Territory_Status__c
                FROM Account
                WHERE Id IN :accountIds
            ];
            
            for (Account acc : accountsToUpdate) {
                acc.Territory_Manager__c = newManagerId;
                acc.Territory_Assignment_Date__c = Date.today();
                acc.Territory_Status__c = 'Active';
            }
            
            update accountsToUpdate;
            
            return accountsToUpdate.size();
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in reassignAccounts: ' + e.getMessage());
            throw new AuraHandledException('Error reassigning accounts: ' + e.getMessage());
        }
    }
}