/**
 * Tests the Lightning controller that records a vehicle sale.
 */
@isTest
private class VehicleSaleControllerTest {
    @TestSetup
    static void setupTestData() {
        VehicleSaleTestDataFactory.createSalesAgent();
    }

    @isTest
    static void shouldCreateSale_WhenControllerReceivesValidRequest() {
        User agent = VehicleSaleTestDataFactory.salesAgent();
        VehicleSaleService.SaleRequest request = VehicleSaleTestDataFactory.buildRequest(1);

        VehicleSaleService.SaleResult result;
        Integer soldCount;
        Test.startTest();
        System.runAs(agent) {
            result = VehicleSaleController.createSale(request);
            soldCount = VehicleSaleController.getSoldCount();
        }
        Test.stopTest();

        Assert.isNotNull(result.recordId, 'The controller should return the new sale');
        Assert.areEqual(1, result.soldCount, 'The controller should return the sold count');
        Assert.areEqual(1, soldCount, 'The sold count should be readable from the controller');
    }

    @isTest
    static void shouldThrowAuraHandled_WhenRequestIsNull() {
        User agent = VehicleSaleTestDataFactory.salesAgent();

        Test.startTest();
        System.runAs(agent) {
            try {
                VehicleSaleController.createSale(null);
                Assert.fail('A missing request should be rejected');
            } catch (AuraHandledException ex) {
                Assert.isTrue(
                    ex.getMessage().contains('Enter the vehicle specs'),
                    'The agent should see a request to enter specs'
                );
            }
        }
        Test.stopTest();
    }
}