create or replace package body ut_error_collector AS

    procedure initialize_without_errors_return_size_0 
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        ut.expect(error_collector.get_size()).to_equal(0);
    end initialize_without_errors_return_size_0;
    
    procedure initialize_without_errors_return_empty_error_list 
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        ut.expect(anydata.convertCollection(error_collector.get_errors())).to_equal(anydata.convertCollection(ct_errors()));
    end initialize_without_errors_return_empty_error_list;
    
    procedure initialize_without_errors_has_no_errors 
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        ut.expect(error_collector.has_errors()).to_be_false();
    end initialize_without_errors_has_no_errors;
    
    procedure initialize_without_errors_contains_error_code_returns_false 
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        ut.expect(error_collector.contains(code => 1)).to_be_false();
    end initialize_without_errors_contains_error_code_returns_false;
    
    procedure initialize_without_errors_get_errors_for_code_returns_empty_list
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        ut.expect(anydata.convertCollection(error_collector.get_errors_for(code => 1))).to_equal(anydata.convertCollection(ct_errors()));
    end initialize_without_errors_get_errors_for_code_returns_empty_list;
    
    procedure initialize_without_errors_get_errors_for_reference_id_returns_empty_list
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        ut.expect(anydata.convertCollection(error_collector.get_errors_for(reference_id => 1))).to_equal(anydata.convertCollection(ct_errors()));
    end initialize_without_errors_get_errors_for_reference_id_returns_empty_list;
    
    procedure initialize_without_errors_clears_error_list
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        error_collector.clear();
        ut.expect(error_collector.get_size()).to_equal(0);
    end initialize_without_errors_clears_error_list;

    procedure initialize_with_one_error_return_size_1
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        error_collector.add_error(ot_error(code         => 12345,
                                           message      => 'Das ist ein Test',
                                           error_stack  => null,
                                           call_stack   => null,
                                           context      => null, 
                                           reference_id => null));
        ut.expect(error_collector.get_size()).to_equal(1);
    end initialize_with_one_error_return_size_1;

    procedure initialize_with_one_error_return_error_list
    is error_collector ot_error_collector;
         o_error ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error := ot_error(code         => 12345,
                            message      => 'Das ist ein Test',
                            error_stack  => null,
                            call_stack   => null,
                            context      => null, 
                            reference_id => null);
        
        error_collector.add_error(error => o_error);
        ut.expect(anydata.convertCollection(error_collector.get_errors())).to_equal(anydata.convertCollection(ct_errors(o_error)));
    end initialize_with_one_error_return_error_list;

    procedure initialize_with_one_error_has_errors
    is  error_collector ot_error_collector;
        o_error ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error := ot_error(code         => 12345,
                            message      => 'Das ist ein Test',
                            error_stack  => null,
                            call_stack   => null,
                            context      => null, 
                            reference_id => null);
        
        error_collector.add_error(error => o_error);
        ut.expect(error_collector.has_errors()).to_be_true();
    end initialize_with_one_error_has_errors;

    procedure initialize_with_one_error_contains_error_code_returns_true
    is error_collector ot_error_collector;
       o_error ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error := ot_error(code         => 12345,
                            message      => 'Das ist ein Test',
                            error_stack  => null,
                            call_stack   => null,
                            context      => null, 
                            reference_id => null);
        error_collector.add_error(error => o_error);
        ut.expect(error_collector.contains(code => 12345)).to_be_true();
    end initialize_with_one_error_contains_error_code_returns_true;

    procedure initialize_with_one_error_get_errors_for_code_returns_list_with_one_error
    is error_collector ot_error_collector;
       o_error ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error := ot_error(code         => 12345,
                            message      => 'Das ist ein Test',
                            error_stack  => null,
                            call_stack   => null,
                            context      => null, 
                            reference_id => null);
        error_collector.add_error(error => o_error);
        ut.expect(anydata.convertCollection(error_collector.get_errors_for(code => 12345))).to_equal(anydata.convertCollection(ct_errors(o_error)));
    end initialize_with_one_error_get_errors_for_code_returns_list_with_one_error;

    procedure initialize_with_one_error_get_errors_for_wrong_reference_id_returns_empty_list
    is error_collector ot_error_collector;
       o_error ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error := ot_error(code         => 12345,
                            message      => 'Das ist ein Test',
                            error_stack  => null,
                            call_stack   => null,
                            context      => null, 
                            reference_id => null);
        error_collector.add_error(error => o_error);
        ut.expect(anydata.convertCollection(error_collector.get_errors_for(reference_id => 999))).to_equal(anydata.convertCollection(ct_errors()));
    end initialize_with_one_error_get_errors_for_wrong_reference_id_returns_empty_list;

    procedure initialize_with_one_error_get_errors_for_correct_reference_id_returns_list_with_one_error
    is error_collector ot_error_collector;
       o_error ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error := ot_error(code         => 12345,
                            message      => 'Das ist ein Test',
                            error_stack  => null,
                            call_stack   => null,
                            context      => null, 
                            reference_id => 100);
        error_collector.add_error(error => o_error);
        ut.expect(anydata.convertCollection(error_collector.get_errors_for(reference_id => 100))).to_equal(anydata.convertCollection(ct_errors(o_error)));
    end initialize_with_one_error_get_errors_for_correct_reference_id_returns_list_with_one_error;

    procedure initialize_with_one_error_get_errors_for_correct_code_returns_list_with_one_error
    is error_collector ot_error_collector;
       o_error ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error := ot_error(code         => 12345,
                            message      => 'Das ist ein Test',
                            error_stack  => null,
                            call_stack   => null,
                            context      => null, 
                            reference_id => null);
        error_collector.add_error(error => o_error);
        ut.expect(anydata.convertCollection(error_collector.get_errors_for(code => 12345))).to_equal(anydata.convertCollection(ct_errors(o_error)));
    end initialize_with_one_error_get_errors_for_correct_code_returns_list_with_one_error;

    procedure initialize_with_one_error_get_errors_for_wrong_code_returns_empty_list
    is error_collector ot_error_collector;
       o_error ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error := ot_error(code         => 12345,
                            message      => 'Das ist ein Test',
                            error_stack  => null,
                            call_stack   => null,
                            context      => null, 
                            reference_id => null);
        error_collector.add_error(error => o_error);
        ut.expect(anydata.convertCollection(error_collector.get_errors_for(code => 999))).to_equal(anydata.convertCollection(ct_errors()));
    end initialize_with_one_error_get_errors_for_wrong_code_returns_empty_list;

    procedure initialize_with_one_error_clears_error_list
is error_collector ot_error_collector;
       o_error ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error := ot_error(code         => 12345,
                            message      => 'Das ist ein Test',
                            error_stack  => null,
                            call_stack   => null,
                            reference_id => null);
        error_collector.add_error(error => o_error);
        error_collector.clear();
        ut.expect(error_collector.get_size()).to_equal(0);
    end initialize_with_one_error_clears_error_list;

    procedure initialize_with_multiple_errors_return_size_2
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        error_collector.add_error(ot_error(code => 12345, message => 'Error 1', error_stack => null, call_stack => null, context => null, reference_id => null));
        error_collector.add_error(ot_error(code => 67890, message => 'Error 2', error_stack => null, call_stack => null, context => null, reference_id => null));
        ut.expect(error_collector.get_size()).to_equal(2);
    end initialize_with_multiple_errors_return_size_2;

    procedure initialize_with_multiple_errors_return_error_list
    is error_collector ot_error_collector;
       o_error1 ot_error;
       o_error2 ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error1 := ot_error(code => 12345, message => 'Error 1', error_stack => null, call_stack => null, context => null, reference_id => null);
        o_error2 := ot_error(code => 67890, message => 'Error 2', error_stack => null, call_stack => null, context => null, reference_id => null);
        error_collector.add_error(error => o_error1);
        error_collector.add_error(error => o_error2);
        ut.expect(anydata.convertCollection(error_collector.get_errors())).to_equal(anydata.convertCollection(ct_errors(o_error1, o_error2)));
    end initialize_with_multiple_errors_return_error_list;

    procedure initialize_with_multiple_errors_has_errors
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        error_collector.add_error(ot_error(code => 12345, message => 'Error 1', error_stack => null, call_stack => null, context => null, reference_id => null));
        error_collector.add_error(ot_error(code => 67890, message => 'Error 2', error_stack => null, call_stack => null, context => null, reference_id => null));
        ut.expect(error_collector.has_errors()).to_be_true();
    end initialize_with_multiple_errors_has_errors;

    procedure initialize_with_multiple_errors_contains_error_code_returns_true
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        error_collector.add_error(ot_error(code => 12345, message => 'Error 1', error_stack => null, call_stack => null, context => null, reference_id => null));
        error_collector.add_error(ot_error(code => 67890, message => 'Error 2', error_stack => null, call_stack => null, context => null, reference_id => null));
        ut.expect(error_collector.contains(code => 12345)).to_be_true();
    end initialize_with_multiple_errors_contains_error_code_returns_true;

    procedure initialize_with_multiple_errors_get_errors_for_code_returns_list_with_two_errors
    is error_collector ot_error_collector;
       o_error1 ot_error;
       o_error2 ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error1 := ot_error(code => 12345, message => 'Error 1', error_stack => null, call_stack => null, context => null, reference_id => null);
        o_error2 := ot_error(code => 12345, message => 'Error 2', error_stack => null, call_stack => null, context => null, reference_id => null);
        error_collector.add_error(error => o_error1);
        error_collector.add_error(error => o_error2);
        ut.expect(anydata.convertCollection(error_collector.get_errors_for(code => 12345))).to_equal(anydata.convertCollection(ct_errors(o_error1, o_error2)));
    end initialize_with_multiple_errors_get_errors_for_code_returns_list_with_two_errors;

    procedure initialize_with_multiple_errors_get_errors_for_wrong_reference_id_returns_empty_list
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        error_collector.add_error(ot_error(code => 12345, message => 'Error 1', error_stack => null, call_stack => null, context => null, reference_id => 100));
        error_collector.add_error(ot_error(code => 67890, message => 'Error 2', error_stack => null, call_stack => null, context => null, reference_id => 200));
        ut.expect(anydata.convertCollection(error_collector.get_errors_for(reference_id => 999))).to_equal(anydata.convertCollection(ct_errors()));
    end initialize_with_multiple_errors_get_errors_for_wrong_reference_id_returns_empty_list;

    procedure initialize_with_multiple_errors_get_errors_for_correct_reference_id_returns_list_with_two_errors
    is error_collector ot_error_collector;
       o_error1 ot_error;
       o_error2 ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error1 := ot_error(code => 12345, message => 'Error 1', error_stack => null, call_stack => null, context => null, reference_id => 100);
        o_error2 := ot_error(code => 67890, message => 'Error 2', error_stack => null, call_stack => null, context => null, reference_id => 100);
        error_collector.add_error(error => o_error1);
        error_collector.add_error(error => o_error2);
        ut.expect(anydata.convertCollection(error_collector.get_errors_for(reference_id => 100))).to_equal(anydata.convertCollection(ct_errors(o_error1, o_error2)));
    end initialize_with_multiple_errors_get_errors_for_correct_reference_id_returns_list_with_two_errors;

    procedure initialize_with_multiple_errors_get_errors_for_correct_code_returns_list_with_two_errors
    is error_collector ot_error_collector;
       o_error1 ot_error;
       o_error2 ot_error;
    begin
        error_collector := new ot_error_collector();
        o_error1 := ot_error(code => 12345, message => 'Error 1', error_stack => null, call_stack => null, context => null, reference_id => null);
        o_error2 := ot_error(code => 12345, message => 'Error 2', error_stack => null, call_stack => null, context => null, reference_id => null);
        error_collector.add_error(error => o_error1);
        error_collector.add_error(error => o_error2);
        ut.expect(anydata.convertCollection(error_collector.get_errors_for(code => 12345))).to_equal(anydata.convertCollection(ct_errors(o_error1, o_error2)));
    end initialize_with_multiple_errors_get_errors_for_correct_code_returns_list_with_two_errors;

    procedure initialize_with_multiple_errors_get_errors_for_wrong_code_returns_empty_list
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        error_collector.add_error(ot_error(code => 12345, message => 'Error 1', error_stack => null, call_stack => null, context => null, reference_id => null));
        error_collector.add_error(ot_error(code => 67890, message => 'Error 2', error_stack => null, call_stack => null, context => null, reference_id => null));
        ut.expect(anydata.convertCollection(error_collector.get_errors_for(code => 999))).to_equal(anydata.convertCollection(ct_errors()));
    end initialize_with_multiple_errors_get_errors_for_wrong_code_returns_empty_list;

    procedure initialize_with_multiple_errors_clears_error_list
    is error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        error_collector.add_error(ot_error(code => 12345, message => 'Error 1', error_stack => null, call_stack => null, context => null, reference_id => null));
        error_collector.add_error(ot_error(code => 67890, message => 'Error 2', error_stack => null, call_stack => null, context => null, reference_id => null));
        error_collector.clear();
        ut.expect(error_collector.get_size()).to_equal(0);
    end initialize_with_multiple_errors_clears_error_list;

    procedure capture_errors_via_exception_no_exception
    is
        error_collector ot_error_collector;
    begin
        error_collector := new ot_error_collector();
        error_collector.capture_exception();
        ut.expect(error_collector.get_size()).to_equal(0);
        ut.expect(error_collector.has_errors()).to_be_false();
    end capture_errors_via_exception_no_exception;

    procedure capture_errors_via_exception_with_user_defined_exception
    is
        error_collector ot_error_collector;
        o_error         ot_error;
    begin
        error_collector := new ot_error_collector();

        o_error := ot_error(code         => -20001,
                            message      => 'Das ist ein Test',
                            error_stack  => null,
                            call_stack   => null,
                            context      => null,
                            reference_id => null);
        raise_application_error(o_error.code, o_error.message);

        exception
            when others then
                error_collector.capture_exception();
                ut.expect(anydata.convertCollection(error_collector.get_errors()))
                  .to_equal(anydata.convertCollection(ct_errors(o_error)))
                  .exclude('ERROR_STACK,CALL_STACK,TIME_STAMP');
        
    end capture_errors_via_exception_with_user_defined_exception;

    procedure capture_errors_via_exception_with_system_exception
    is
        error_collector ot_error_collector;
        o_error         ot_error;
        co_error_code       constant number := -01403;
    begin
        error_collector := new ot_error_collector();

        o_error := ot_error(code         => co_error_code,
                            message      => replace(sqlerrm(co_error_code),'ORA-01403: ',''),
                            error_stack  => null,
                            call_stack   => null,
                            context      => null,
                            reference_id => null);
        raise no_data_found;  -- nosonar

        exception
            when no_data_found 
            then error_collector.capture_exception(); 
                 ut.expect(anydata.convertCollection(error_collector.get_errors()))
                   .to_equal(anydata.convertCollection(ct_errors(o_error)))
                   .exclude( 'ERROR_STACK,CALL_STACK,TIME_STAMP');
        
    end capture_errors_via_exception_with_system_exception;

end ut_error_collector;
/