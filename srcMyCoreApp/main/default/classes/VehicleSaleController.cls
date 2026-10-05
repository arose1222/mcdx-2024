/**
 * Lightning entry point for recording a vehicle sale.
 */
public with sharing class VehicleSaleController {
    /**
     * Creates one vehicle sale from the agent form.
     * @param request Vehicle specs and sale details.
     * @return Created sale and the number of vehicles sold.
     */
    @AuraEnabled
    public static VehicleSaleService.SaleResult createSale(VehicleSaleService.SaleRequest request) {
        try {
            return VehicleSaleService.createSale(request);
        } catch (VehicleSaleService.VehicleSaleException ex) {
            throw handled(ex.getMessage());
        }
    }

    /**
     * Returns how many vehicle sales are marked Sold.
     * @return Sold vehicle count.
     */
    @AuraEnabled(cacheable=true)
    public static Integer getSoldCount() {
        return VehicleSaleService.getSoldCount();
    }

    private static AuraHandledException handled(String message) {
        AuraHandledException error = new AuraHandledException(message);
        error.setMessage(message);
        return error;
    }
}