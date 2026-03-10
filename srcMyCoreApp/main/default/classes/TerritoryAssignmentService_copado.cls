/**
 * @description Service class for automated territory assignment on Account records
 * @author Copado DevOps Demo
 * @date 2026-03-02
 * @modified 2026-03-09 - Added regional hierarchy support (NA, LATAM, EMEA, APAC)
 */
public with sharing class TerritoryAssignmentService_copado {

    // Territory code validation pattern: TER-XX-9999
    private static final String TERRITORY_CODE_PATTERN = '^TER-[A-Z]{2}-[0-9]{4}$';

    // Territory Status values
    private static final String STATUS_ASSIGNED = 'Active';
    private static final String STATUS_PENDING = 'Pending Review';
    private static final String STATUS_UNASSIGNED = 'Draft';
    
    // Test mode flag for dependency injection
    @TestVisible
    private static Boolean testMode = false;
    
    @TestVisible
    private static Map<String, TerritoryMapping> testMappings = new Map<String, TerritoryMapping>();

    /**
     * @description Wrapper class for territory mapping data
     */
    public class TerritoryMapping {
        public Id territoryManagerId;
        public String region;
        public Id regionalManagerId;
        
        public TerritoryMapping(Id territoryManagerId, String region, Id regionalManagerId) {
            this.territoryManagerId = territoryManagerId;
            this.region = region;
            this.regionalManagerId = regionalManagerId;
        }
    }

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

            // Get territory manager mappings with regional data
            Map<String, TerritoryMapping> territoryMappingMap = getTerritoryMappings(territoryCodes);

            // Process each account
            for (Account acc : accountsToProcess) {
                processAccountAssignment(acc, territoryMappingMap);
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
     * @description Retrieves territory mappings from Custom Metadata including regional data
     * @param territoryCodes Set of territory codes to look up
     * @return Map of territory code to TerritoryMapping wrapper
     */
    private static Map<String, TerritoryMapping> getTerritoryMappings(Set<String> territoryCodes) {
        // Use test mappings if in test mode
        if (testMode) {
            return testMappings;
        }
        
        Map<String, TerritoryMapping> mappingMap = new Map<String, TerritoryMapping>();

        // Query Custom Metadata for territory mappings with regional information
        List<Territory_Manager_Mapping__mdt> mappings = [
            SELECT Territory_Code__c, 
                   Territory_Manager__c, 
                   Region__c,
                   Regional_Manager__c
            FROM Territory_Manager_Mapping__mdt
            WHERE Territory_Code__c IN :territoryCodes
            AND Active__c = true
        ];

        for (Territory_Manager_Mapping__mdt mapping : mappings) {
            if (String.isNotBlank(mapping.Territory_Manager__c)) {
                Id territoryManagerId = (Id)mapping.Territory_Manager__c;
                String region = mapping.Region__c;
                Id regionalManagerId = String.isNotBlank(mapping.Regional_Manager__c) 
                    ? (Id)mapping.Regional_Manager__c 
                    : null;
                
                TerritoryMapping territoryMapping = new TerritoryMapping(
                    territoryManagerId, 
                    region, 
                    regionalManagerId
                );
                mappingMap.put(mapping.Territory_Code__c, territoryMapping);
            }
        }

        return mappingMap;
    }

    /**
     * @description Processes territory assignment for a single account
     * @param acc Account record to process
     * @param territoryMappingMap Map of territory codes to TerritoryMapping wrappers
     */
    private static void processAccountAssignment(Account acc, Map<String, TerritoryMapping> territoryMappingMap) {
        // Validate territory code format
        if (!validateTerritoryCode(acc.Territory_Code__c)) {
            updateTerritoryStatus(acc, false);
            clearTerritoryFields(acc);
            return;
        }

        // Check if mapping exists for this territory
        if (territoryMappingMap.containsKey(acc.Territory_Code__c)) {
            TerritoryMapping mapping = territoryMappingMap.get(acc.Territory_Code__c);
            
            // Assign territory manager
            acc.Territory_Manager__c = mapping.territoryManagerId;
            acc.Territory_Assignment_Date__c = Date.today();
            
            // Assign region
            acc.Region__c = mapping.region;
            
            // Assign regional manager (if mapping has value)
            if (mapping.regionalManagerId != null) {
                acc.Regional_Manager__c = mapping.regionalManagerId;
            }
            
            updateTerritoryStatus(acc, true);
        } else {
            // Valid code but no manager assigned - try to derive region
            String derivedRegion = deriveRegionFromTerritoryCode(acc.Territory_Code__c);
            if (derivedRegion != null) {
                acc.Region__c = derivedRegion;
            }
            acc.Territory_Manager__c = null;
            acc.Regional_Manager__c = null;
            updateTerritoryStatus(acc, false);
        }
    }

    /**
     * @description Clears territory-related fields on the account
     * @param acc Account record to update
     */
    private static void clearTerritoryFields(Account acc) {
        acc.Territory_Manager__c = null;
        acc.Region__c = null;
        acc.Regional_Manager__c = null;
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
    
    /**
     * @description Derives region from territory code country prefix
     * This is a fallback method if Custom Metadata doesn't have region configured
     * @param territoryCode The territory code (e.g., TER-US-0001)
     * @return String region code (NA, LATAM, EMEA, APAC) or null
     */
    public static String deriveRegionFromTerritoryCode(String territoryCode) {
        if (!validateTerritoryCode(territoryCode)) {
            return null;
        }
        
        // Extract country code (characters 4-5 in TER-XX-9999)
        String countryCode = territoryCode.substring(4, 6);
        
        // Map country codes to regions
        Map<String, String> countryToRegion = new Map<String, String>{
            // North America
            'US' => 'NA', 'CA' => 'NA', 'MX' => 'NA',
            
            // Latin America
            'BR' => 'LATAM', 'AR' => 'LATAM', 'CL' => 'LATAM', 'CO' => 'LATAM',
            'PE' => 'LATAM', 'VE' => 'LATAM', 'EC' => 'LATAM', 'CR' => 'LATAM',
            
            // EMEA
            'GB' => 'EMEA', 'DE' => 'EMEA', 'FR' => 'EMEA', 'IT' => 'EMEA',
            'ES' => 'EMEA', 'NL' => 'EMEA', 'SE' => 'EMEA', 'CH' => 'EMEA',
            'AE' => 'EMEA', 'SA' => 'EMEA', 'ZA' => 'EMEA', 'NG' => 'EMEA',
            
            // APAC
            'AU' => 'APAC', 'NZ' => 'APAC', 'JP' => 'APAC', 'CN' => 'APAC',
            'IN' => 'APAC', 'SG' => 'APAC', 'HK' => 'APAC', 'KR' => 'APAC',
            'TH' => 'APAC', 'MY' => 'APAC', 'ID' => 'APAC', 'PH' => 'APAC'
        };
        
        return countryToRegion.get(countryCode);
    }
}