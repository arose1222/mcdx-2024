/**
 * Creates users and vehicle sale requests for Vehicle Sale tests.
 */
@isTest
public class VehicleSaleTestDataFactory {
    private static final Integer BULK_SIZE = 251;

    /**
     * Inserts a standard user who can record vehicle sales.
     * Call this from @TestSetup only. Vehicle records must be created later with System.runAs.
     * @return Sales agent user.
     */
    public static User createSalesAgent() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniqueKey = String.valueOf(DateTime.now().getTime());
        User agent = new User(
            FirstName = 'Vehicle',
            LastName = 'VehicleSalesAgent',
            Alias = 'vsagent',
            Email = 'vehicle.sales.agent.' + uniqueKey + '@example.com',
            Username = 'vehicle.sales.agent.' + uniqueKey + '@example.com',
            CommunityNickname = 'vsagent' + uniqueKey.right(8),
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = standardProfile.Id
        );
        insert agent;

        PermissionSet vehicleSales = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Vehicle_Sales_Agent'
            LIMIT 1
        ];
        insert new PermissionSetAssignment(AssigneeId = agent.Id, PermissionSetId = vehicleSales.Id);
        return agent;
    }

    /**
     * Builds one valid sold-vehicle request.
     * @param sequence Value used to keep the VIN unique.
     * @return Sale request.
     */
    public static VehicleSaleService.SaleRequest buildRequest(Integer sequence) {
        VehicleSaleService.SaleRequest request = new VehicleSaleService.SaleRequest();
        request.vin = vinFor(sequence);
        request.make = 'Toyota';
        request.model = 'Camry';
        request.modelYear = 2024;
        request.trim = 'SE';
        request.exteriorColor = 'Silver';
        request.interiorColor = 'Black';
        request.mileage = 12000;
        request.bodyStyle = 'Sedan';
        request.fuelType = 'Gasoline';
        request.transmission = 'Automatic';
        request.drivetrain = 'FWD';
        request.salePrice = 28500;
        request.saleDate = Date.today();
        request.buyerName = 'Jordan Lee';
        request.status = VehicleSaleService.STATUS_SOLD;
        return request;
    }

    /**
     * Builds 251 valid sold-vehicle requests.
     * @return Bulk sale requests.
     */
    public static List<VehicleSaleService.SaleRequest> buildBulkRequests() {
        List<VehicleSaleService.SaleRequest> requests = new List<VehicleSaleService.SaleRequest>();
        for (Integer sequence = 1; sequence <= BULK_SIZE; sequence++) {
            requests.add(buildRequest(sequence));
        }
        return requests;
    }

    /**
     * Returns the sales agent created in test setup.
     * @return Sales agent user.
     */
    public static User salesAgent() {
        return [
            SELECT Id
            FROM User
            WHERE LastName = 'VehicleSalesAgent'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
    }

    private static String vinFor(Integer sequence) {
        return '1HGCM82633A' + String.valueOf(sequence).leftPad(6, '0');
    }
}