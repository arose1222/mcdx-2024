/**
 * @description Service class for automated territory assignment on Account records
 * @author Copado DevOps Demo
 * @date 2026-03-02
 */
public with sharing class TerritoryAssignmentService_copado {
    
    // Territory code validation pattern: TER-XX-9999
    private static final String TERRITORY_CODE_PATTERN = '^TER-[A-Z]{2}-[0-9]{4}$';
    
    // Territory Status values
    private static final String STATUS_ASSIGNED = 'Active';
    private static final String STATUS_PENDING = 'Pending Review';
    private static final String STATUS_UNASSIGNED = 'Draft';
    
    /**
     * @description Main entry point for territory assignment logic
     * @param accounts List of Account records to process
     */
    public static void assignTerritoryManagers(List<Account> accounts) {
        try {
            // Filter accounts that have territory codes
            List<Account> accountsToProcess = new List<Account>();
            Set<String> territoryCodes = new Set<String>();
            
            for (Account acc : accounts) {
                if (String.isNotBlank(acc.Territory_Code__c)) {
                    accountsToProcess.add(acc);
                    territoryCodes.add(acc.Territory_Code__c);
                }
            }
            
            if (accountsToProcess.isEmpty()) {
                return;
            }
            
            // Get territory manager mappings
            Map<String, Id> territoryManagerMap = getTerritoryManagerMap(territoryCodes);
            
            // Process each account
            for (Account acc : accountsToProcess) {
                processAccountAssignment(acc, territoryManagerMap);
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in assignTerritoryManagers: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }
    }
    
    /**
     * @description Validates territory code format
     * @param territoryCode The territory code to validate
     * @return Boolean true if valid, false otherwise
     */
    public static Boolean validateTerritoryCode(String territoryCode) {
        if (String.isBlank(territoryCode)) {
            return false;
        }
        
        Pattern pattern = Pattern.compile(TERRITORY_CODE_PATTERN);
        Matcher matcher = pattern.matcher(territoryCode);
        return matcher.matches();
    }
    
    /**
     * @description Retrieves territory manager mappings from Custom Metadata
     * @param territoryCodes Set of territory codes to look up
     * @return Map of territory code to User ID
     */
    private static Map<String, Id> getTerritoryManagerMap(Set<String> territoryCodes) {
        Map<String, Id> managerMap = new Map<String, Id>();
        
        // Query Custom Metadata for territory mappings
        List<Territory_Manager_Mapping__mdt> mappings = [
            SELECT Territory_Code__c, Territory_Manager__c
            FROM Territory_Manager_Mapping__mdt
            WHERE Territory_Code__c IN :territoryCodes
            AND Active__c = true
        ];
        
        for (Territory_Manager_Mapping__mdt mapping : mappings) {
            if (String.isNotBlank(mapping.Territory_Manager__c)) {
                managerMap.put(mapping.Territory_Code__c, (Id)mapping.Territory_Manager__c);
            }
        }
        
        return managerMap;
    }
    
    /**
     * @description Processes territory assignment for a single account
     * @param acc Account record to process
     * @param territoryManagerMap Map of territory codes to manager IDs
     */
    private static void processAccountAssignment(Account acc, Map<String, Id> territoryManagerMap) {
        // Validate territory code format
        if (!validateTerritoryCode(acc.Territory_Code__c)) {
            updateTerritoryStatus(acc, false);
            return;
        }
        
        // Check if manager exists for this territory
        if (territoryManagerMap.containsKey(acc.Territory_Code__c)) {
            Id managerId = territoryManagerMap.get(acc.Territory_Code__c);
            acc.Territory_Manager__c = managerId;
            acc.Territory_Assignment_Date__c = Date.today();
            updateTerritoryStatus(acc, true);
        } else {
            // Valid code but no manager assigned
            acc.Territory_Manager__c = null;
            updateTerritoryStatus(acc, false);
        }
    }
    
    /**
     * @description Updates territory status based on assignment outcome
     * @param acc Account record to update
     * @param managerFound Whether a manager was found and assigned
     */
    private static void updateTerritoryStatus(Account acc, Boolean managerFound) {
        if (managerFound) {
            acc.Territory_Status__c = STATUS_ASSIGNED;
        } else if (validateTerritoryCode(acc.Territory_Code__c)) {
            acc.Territory_Status__c = STATUS_PENDING;
        } else {
            acc.Territory_Status__c = STATUS_UNASSIGNED;
        }
    }
}