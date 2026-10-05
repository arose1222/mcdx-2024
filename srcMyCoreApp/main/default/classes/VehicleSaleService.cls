/**
 * Creates Vehicle Sale records from the specifications a sales agent enters.
 */
public with sharing class VehicleSaleService {
    public class VehicleSaleException extends Exception {
    }

    /**
     * Specifications and sale details submitted from the vehicle sale form.
     */
    public class SaleRequest {
        @AuraEnabled public String vin { get; set; }
        @AuraEnabled public String make { get; set; }
        @AuraEnabled public String model { get; set; }
        @AuraEnabled public Integer modelYear { get; set; }
        @AuraEnabled public String trim { get; set; }
        @AuraEnabled public String exteriorColor { get; set; }
        @AuraEnabled public String interiorColor { get; set; }
        @AuraEnabled public Integer mileage { get; set; }
        @AuraEnabled public String bodyStyle { get; set; }
        @AuraEnabled public String fuelType { get; set; }
        @AuraEnabled public String transmission { get; set; }
        @AuraEnabled public String drivetrain { get; set; }
        @AuraEnabled public Decimal salePrice { get; set; }
        @AuraEnabled public Date saleDate { get; set; }
        @AuraEnabled public String buyerName { get; set; }
        @AuraEnabled public String status { get; set; }
    }

    /**
     * Identifiers returned after a vehicle sale is created.
     */
    public class SaleResult {
        @AuraEnabled public Id recordId { get; set; }
        @AuraEnabled public String saleNumber { get; set; }
        @AuraEnabled public String vehicleSummary { get; set; }
        @AuraEnabled public Integer soldCount { get; set; }
    }

    public static final String STATUS_SOLD = 'Sold';
    private static final Integer MIN_MODEL_YEAR = 1900;
    private static final Pattern VIN_PATTERN = Pattern.compile('^[A-HJ-NPR-Z0-9]{17}$');
    private static final Set<String> BODY_STYLES = new Set<String>{
        'Sedan', 'Coupe', 'Hatchback', 'Wagon', 'SUV', 'Truck', 'Van', 'Convertible'
    };
    private static final Set<String> FUEL_TYPES = new Set<String>{
        'Gasoline', 'Diesel', 'Hybrid', 'Plug-in Hybrid', 'Electric'
    };
    private static final Set<String> TRANSMISSIONS = new Set<String>{ 'Automatic', 'Manual' };
    private static final Set<String> DRIVETRAINS = new Set<String>{ 'FWD', 'RWD', 'AWD', '4WD' };
    private static final Set<String> STATUSES = new Set<String>{ 'Sold', 'Pending', 'Cancelled' };

    /**
     * Creates one vehicle sale and returns the updated sold count.
     * @param request Vehicle specs and sale details.
     * @return Created sale and the number of vehicles sold.
     */
    public static SaleResult createSale(SaleRequest request) {
        List<SaleResult> results = createSales(new List<SaleRequest>{ request });
        return results[0];
    }

    /**
     * Creates vehicle sales in one transaction.
     * @param requests Vehicle specs and sale details.
     * @return Created sales and the number of vehicles sold.
     */
    public static List<SaleResult> createSales(List<SaleRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            throw new VehicleSaleException('Enter the vehicle specs before saving.');
        }

        List<Vehicle_Sale__c> sales = new List<Vehicle_Sale__c>();
        for (Integer index = 0; index < requests.size(); index++) {
            sales.add(toRecord(requests[index], index, requests.size()));
        }

        try {
            Database.insert(sales, AccessLevel.USER_MODE);
        } catch (DmlException ex) {
            throw new VehicleSaleException(saleSaveMessage(ex), ex);
        }
        return toResults(sales);
    }

    /**
     * Counts vehicle sales whose status is Sold.
     * @return Number of sold vehicles the current user can see.
     */
    public static Integer getSoldCount() {
        return [SELECT COUNT() FROM Vehicle_Sale__c WHERE Status__c = :STATUS_SOLD WITH USER_MODE];
    }

    private static Vehicle_Sale__c toRecord(SaleRequest request, Integer index, Integer total) {
        if (request == null) {
            throw new VehicleSaleException('Enter the vehicle specs before saving.');
        }

        String prefix = total == 1 ? '' : 'Vehicle ' + String.valueOf(index + 1) + ': ';
        String vin = normalize(request.vin);
        String make = normalize(request.make);
        String model = normalize(request.model);
        Integer maxYear = Date.today().year() + 1;

        if (String.isBlank(vin) || !VIN_PATTERN.matcher(vin.toUpperCase()).matches()) {
            throw new VehicleSaleException(prefix + 'Enter a 17-character VIN. The letters I, O, and Q are not used.');
        }
        if (String.isBlank(make)) {
            throw new VehicleSaleException(prefix + 'Enter the make.');
        }
        if (String.isBlank(model)) {
            throw new VehicleSaleException(prefix + 'Enter the model.');
        }
        if (request.modelYear == null || request.modelYear < MIN_MODEL_YEAR || request.modelYear > maxYear) {
            throw new VehicleSaleException(prefix + 'Enter a model year from ' + MIN_MODEL_YEAR + ' through ' + maxYear + '.');
        }
        if (request.mileage != null && request.mileage < 0) {
            throw new VehicleSaleException(prefix + 'Mileage cannot be negative.');
        }
        if (request.salePrice == null || request.salePrice <= 0) {
            throw new VehicleSaleException(prefix + 'Enter a sale price greater than zero.');
        }
        if (request.saleDate == null) {
            throw new VehicleSaleException(prefix + 'Enter the sale date.');
        }

        String status = String.isBlank(request.status) ? STATUS_SOLD : request.status.trim();
        requireAllowed(request.bodyStyle, BODY_STYLES, prefix + 'Choose a body style from the list.');
        requireAllowed(request.fuelType, FUEL_TYPES, prefix + 'Choose a fuel type from the list.');
        requireAllowed(request.transmission, TRANSMISSIONS, prefix + 'Choose a transmission from the list.');
        requireAllowed(request.drivetrain, DRIVETRAINS, prefix + 'Choose a drivetrain from the list.');
        if (!STATUSES.contains(status)) {
            throw new VehicleSaleException(prefix + 'Choose Sold, Pending, or Cancelled.');
        }

        return new Vehicle_Sale__c(
            VIN__c = vin.toUpperCase(),
            Make__c = make,
            Model__c = model,
            Model_Year__c = request.modelYear,
            Trim__c = normalize(request.trim),
            Exterior_Color__c = normalize(request.exteriorColor),
            Interior_Color__c = normalize(request.interiorColor),
            Mileage__c = request.mileage,
            Body_Style__c = normalize(request.bodyStyle),
            Fuel_Type__c = normalize(request.fuelType),
            Transmission__c = normalize(request.transmission),
            Drivetrain__c = normalize(request.drivetrain),
            Sale_Price__c = request.salePrice,
            Sale_Date__c = request.saleDate,
            Buyer_Name__c = normalize(request.buyerName),
            Status__c = status
        );
    }

    private static void requireAllowed(String value, Set<String> allowed, String message) {
        if (String.isNotBlank(value) && !allowed.contains(value.trim())) {
            throw new VehicleSaleException(message);
        }
    }

    private static String normalize(String value) {
        return String.isBlank(value) ? null : value.trim();
    }

    private static String saleSaveMessage(DmlException ex) {
        String detail = ex.getNumDml() > 0 ? ex.getDmlMessage(0) : ex.getMessage();
        return 'The vehicle sale could not be saved. ' + detail;
    }

    private static List<SaleResult> toResults(List<Vehicle_Sale__c> sales) {
        Map<Id, Vehicle_Sale__c> savedById = new Map<Id, Vehicle_Sale__c>([
            SELECT Id, Name, Vehicle_Summary__c
            FROM Vehicle_Sale__c
            WHERE Id IN :sales
            WITH USER_MODE
        ]);
        Integer soldCount = getSoldCount();
        List<SaleResult> results = new List<SaleResult>();
        for (Vehicle_Sale__c sale : sales) {
            Vehicle_Sale__c saved = savedById.get(sale.Id);
            SaleResult result = new SaleResult();
            result.recordId = saved.Id;
            result.saleNumber = saved.Name;
            result.vehicleSummary = saved.Vehicle_Summary__c;
            result.soldCount = soldCount;
            results.add(result);
        }
        return results;
    }
}