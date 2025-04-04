create or replace package ut_error_collector as

  -- %suite(error_collector)
  -- %suitepath(ut.elox)

  -- %context(Initialize an error collector)
    -- %name(intitialize)

    -- %context(without any errors)
      -- %name(no_errors)

      -- %test(return a size of: 0)
      procedure initialize_without_errors_return_size_0;

      -- %test(returns an empty error list)
      procedure initialize_without_errors_return_empty_error_list;

      -- %test(has no errors)
      procedure initialize_without_errors_has_no_errors;

      -- %test(returns false when checking if it contains an error code)
      procedure initialize_without_errors_contains_error_code_returns_false;

      -- %test(returns an empty list when getting errors by code)
      procedure initialize_without_errors_get_errors_for_code_returns_empty_list;

      -- %test(returns an empty list when getting errors by reference id)
      procedure initialize_without_errors_get_errors_for_reference_id_returns_empty_list;

      -- %test(clearing the error list does not raise an error)
      procedure initialize_without_errors_clears_error_list;

    -- %endcontext
  

    -- %context(with one error)
        -- %name(one_error)

        -- %test(return a size of: 1)
        procedure initialize_with_one_error_return_size_1;

        -- %test(returns a list with one error)
        procedure initialize_with_one_error_return_error_list;

        -- %test(has errors)
        procedure initialize_with_one_error_has_errors;

        -- %test(returns true when checking if it contains an error code)
        procedure initialize_with_one_error_contains_error_code_returns_true;

        -- %test(returns a list with one error when getting errors by code)
        procedure initialize_with_one_error_get_errors_for_code_returns_list_with_one_error;

        -- %test(returns an empty list when getting errors by wrong reference id)
        procedure initialize_with_one_error_get_errors_for_wrong_reference_id_returns_empty_list;

        -- %test(returns a list with one error when getting errors by correct reference id)
        procedure initialize_with_one_error_get_errors_for_correct_reference_id_returns_list_with_one_error;

        -- %test(return a list with one error when getting errors by correct code)
        procedure initialize_with_one_error_get_errors_for_correct_code_returns_list_with_one_error;

        -- %test(return an empty list when getting errors by wrong code)
        procedure initialize_with_one_error_get_errors_for_wrong_code_returns_empty_list;

        -- %test(clearing the error list removes the error)
        procedure initialize_with_one_error_clears_error_list;

    -- %endcontext

    -- %context(with multiple errors)
        -- %name(multiple_errors)

        -- %test(return a size of: 2)
        procedure initialize_with_multiple_errors_return_size_2;

        -- %test(returns a list with two errors)
        procedure initialize_with_multiple_errors_return_error_list;

        -- %test(has errors)
        procedure initialize_with_multiple_errors_has_errors;

        -- %test(returns true when checking if it contains an error code)
        procedure initialize_with_multiple_errors_contains_error_code_returns_true;

        -- %test(returns a list with two errors when getting errors by code)
        procedure initialize_with_multiple_errors_get_errors_for_code_returns_list_with_two_errors;

        -- %test(returns an empty list when getting errors by wrong reference id)
        procedure initialize_with_multiple_errors_get_errors_for_wrong_reference_id_returns_empty_list;

        -- %test(returns a list with two errors when getting errors by correct reference id)
        procedure initialize_with_multiple_errors_get_errors_for_correct_reference_id_returns_list_with_two_errors;

        -- %test(return a list with two errors when getting errors by correct code)
        procedure initialize_with_multiple_errors_get_errors_for_correct_code_returns_list_with_two_errors;

        -- %test(return an empty list when getting errors by wrong code)
        procedure initialize_with_multiple_errors_get_errors_for_wrong_code_returns_empty_list;

        -- %test(clearing the error list removes all errors)
        procedure initialize_with_multiple_errors_clears_error_list;

        -- %endcontext
  -- %endcontext

  -- %context(capture errors)
    -- %name(capture_errors)

    -- %context(via default methods)
      -- %name(using_capture_exception)

      -- %test(with no exception happening, the error list is empty)
      procedure capture_errors_via_exception_no_exception;
      
      -- %test(with an user defined exception happening, the error list contains one error)
      procedure capture_errors_via_exception_with_user_defined_exception;

      -- %test(with a system exception happening, the error list contains one error)
      procedure capture_errors_via_exception_with_system_exception;
    -- %endcontext

  -- %endcontext
end ut_error_collector;
/