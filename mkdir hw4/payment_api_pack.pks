create or replace package payment_api_pack is
  /*
  Автор: Костина Екатерина
  Описание: API для сущностей “Платеж”  
   */

  --статусы платежа
  c_new_status constant payment.status%type := 0;
  c_success_status constant payment.status%type := 1;
  c_error_status constant payment.status%type := 2;
  c_cancel_status constant payment.status%type := 3;
 
  --сообщения ошибок
  c_error_msg_empty_field_id    constant varchar2(100 char) := 'ID поля не может быть пустым';
  c_error_msg_empty_field_value constant varchar2(100 char) := 'Значение в поле не может быть пустым';
  c_error_msg_empty_collection  constant varchar2(100 char) := 'Коллекция не содержит данных';
  c_error_msg_empty_object_id   constant varchar2(100 char) := 'ID объекта не может быть пустым';
  c_error_msg_empty_reason      constant varchar2(100 char) := 'Причина не может быть пустой';
  c_error_msg_not_new_status    constant varchar2(100 char) := 'Статус платежа не в статусе "Создан". ID платежа: ';
 
  -- коды ошибок
  c_error_code_invalid_input_parameter constant number(10) := -20101;
  c_error_code_invalid_payment_status  constant number(10) := -20102;
 
  -- объекты исключений
  e_invalid_input_parameter exception;
  pragma exception_init(e_invalid_input_parameter, c_error_code_invalid_input_parameter);
 
  -- Создание платежа
  function create_payment (p_from_client_id payment.from_client_id%type,
                           p_to_client_id payment.to_client_id%type,
                           p_summa payment.summa%type,
                           p_currency_id payment.currency_id%type,
                           p_create_dtime payment.create_dtime%type,
                           p_payment_detail t_payment_detail_array) return payment.payment_id%type;
                          
  -- Перевод платежа в ошибочный статус с описанием причины
  procedure fail_payment (p_payment_id payment.payment_id%type,
                          p_reason payment.status_change_reason%type);
    
  -- Отмена платежа
  procedure cancel_payment (p_payment_id  payment.payment_id%type,
                            p_reason payment.status_change_reason%type);
    
  -- Завершение платежа
  procedure successful_finish_payment (p_payment_id payment.payment_id%type);

end payment_api_pack;
/