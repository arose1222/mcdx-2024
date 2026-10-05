/**
 * Tests vehicle sale creation, sold-count tracking, and rejected specs.
 */
@isTest
private class VehicleSaleServiceTest {
    @TestSetup
    static void setupTestData() {
        VehicleSaleTestDataFactory.createSalesAgent();
    }

    @isTest
    static void shouldCreateSale_WhenRequestIsValid() {
        User agent = VehicleSaleTestDataFactory.salesAgent();
        VehicleSaleService.SaleRequest request = VehicleSaleTestDataFactory.buildRequest(1);

        VehicleSaleService.SaleResult result;
        Test.startTest();
        System.runAs(agent) {
            result = VehicleSaleService.createSale(request);
        }
        Test.stopTest();

        Vehicle_Sale__c sale = [
            SELECT VIN__c, Make__c, Model__c, Model_Year__c, Sale_Price__c, Status__c
            FROM Vehicle_Sale__c
            WHERE Id = :result.recordId
        ];
        Assert.areEqual('1HGCM82633A000001', sale.VIN__c, 'VIN should be stored in uppercase');
        Assert.areEqual('Toyota', sale.Make__c, 'Make should be saved');
        Assert.areEqual('Camry', sale.Model__c, 'Model should be saved');
        Assert.areEqual(2024, sale.Model_Year__c, 'Model year should be saved');
        Assert.areEqual(28500, sale.Sale_Price__c, 'Sale price should be saved');
        Assert.areEqual(VehicleSaleService.STATUS_SOLD, sale.Status__c, 'New sales should be sold');
        Assert.areEqual('2024 Toyota Camry', result.vehicleSummary, 'Summary should combine year, make, and model');
        Assert.areEqual(1, result.soldCount, 'Sold count should include the new sale');
        Assert.isTrue(result.saleNumber.startsWith('VS-'), 'Sale number should use the VS- prefix');
    }

    @isTest
    static void shouldCreateSales_WhenBulkRequestsAreValid() {
        User agent = VehicleSaleTestDataFactory.salesAgent();
        List<VehicleSaleService.SaleRequest> requests = VehicleSaleTestDataFactory.buildBulkRequests();
        Assert.areEqual(251, requests.size(), 'Bulk setup should contain 251 vehicles');

        List<VehicleSaleService.SaleResult> results;
        Test.startTest();
        System.runAs(agent) {
            results = VehicleSaleService.createSales(requests);
        }
        Test.stopTest();

        Integer savedCount = [SELECT COUNT() FROM Vehicle_Sale__c];
        Assert.areEqual(251, results.size(), 'Each request should return a result');
        Assert.areEqual(251, savedCount, 'All 251 vehicle sales should be saved');
        Assert.areEqual(251, results[0].soldCount, 'Sold count should include every bulk sale');
    }

    @isTest
    static void shouldReturnSoldCount_WhenPendingSalesExist() {
        User agent = VehicleSaleTestDataFactory.salesAgent();
        VehicleSaleService.SaleRequest sold = VehicleSaleTestDataFactory.buildRequest(1);
        VehicleSaleService.SaleRequest pending = VehicleSaleTestDataFactory.buildRequest(2);
        pending.status = 'Pending';

        Integer soldCount;
        Test.startTest();
        System.runAs(agent) {
            VehicleSaleService.createSales(new List<VehicleSaleService.SaleRequest>{ sold, pending });
            soldCount = VehicleSaleService.getSoldCount();
        }
        Test.stopTest();

        Assert.areEqual(1, soldCount, 'Pending sales should not be included in the sold count');
    }

    @isTest
    static void shouldThrow_WhenRequestIsNull() {
        User agent = VehicleSaleTestDataFactory.salesAgent();

        Test.startTest();
        System.runAs(agent) {
            try {
                VehicleSaleService.createSale(null);
                Assert.fail('A missing request should be rejected');
            } catch (VehicleSaleService.VehicleSaleException ex) {
                Assert.isTrue(
                    ex.getMessage().contains('Enter the vehicle specs'),
                    'The message should ask the agent to enter specs'
                );
            }
        }
        Test.stopTest();
    }

    @isTest
    static void shouldThrow_WhenMakeIsBlank() {
        User agent = VehicleSaleTestDataFactory.salesAgent();
        VehicleSaleService.SaleRequest request = VehicleSaleTestDataFactory.buildRequest(1);
        request.make = ' ';

        Test.startTest();
        System.runAs(agent) {
            try {
                VehicleSaleService.createSale(request);
                Assert.fail('A blank make should be rejected');
            } catch (VehicleSaleService.VehicleSaleException ex) {
                Assert.isTrue(ex.getMessage().contains('Enter the make'), 'The message should ask for the make');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void shouldThrow_WhenVinIsInvalid() {
        User agent = VehicleSaleTestDataFactory.salesAgent();
        VehicleSaleService.SaleRequest request = VehicleSaleTestDataFactory.buildRequest(1);
        request.vin = 'SHORT';

        Test.startTest();
        System.runAs(agent) {
            try {
                VehicleSaleService.createSale(request);
                Assert.fail('A short VIN should be rejected');
            } catch (VehicleSaleService.VehicleSaleException ex) {
                Assert.isTrue(ex.getMessage().contains('17-character VIN'), 'The message should describe the VIN');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void shouldThrow_WhenSalePriceIsNotPositive() {
        User agent = VehicleSaleTestDataFactory.salesAgent();
        VehicleSaleService.SaleRequest request = VehicleSaleTestDataFactory.buildRequest(1);
        request.salePrice = 0;

        Test.startTest();
        System.runAs(agent) {
            try {
                VehicleSaleService.createSale(request);
                Assert.fail('A zero sale price should be rejected');
            } catch (VehicleSaleService.VehicleSaleException ex) {
                Assert.isTrue(
                    ex.getMessage().contains('sale price greater than zero'),
                    'The message should require a positive sale price'
                );
            }
        }
        Test.stopTest();
    }
}