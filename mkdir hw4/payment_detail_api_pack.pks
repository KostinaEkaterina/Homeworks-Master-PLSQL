create or replace package payment_detail_api_pack is
  /*
  Автор: Костина Екатерина
  Описание: API для сущностей “Детали платежа” 
  */
	--сообщения ошибок
  c_error_msg_empty_field_id    constant varchar2(100 char) := 'ID поля не может быть пустым';
  c_error_msg_empty_field_value constant varchar2(100 char) := 'Значение в поле не может быть пустым';
  c_error_msg_empty_collection  constant varchar2(100 char) := 'Коллекция не содержит данных';
  c_error_msg_empty_object_id   constant varchar2(100 char) := 'ID объекта не может быть пустым';
  
	--коды ошибок
  c_error_code_invalid_input_parameter constant number(10) := -20101;
 
  -- объекты исключений
  e_invalid_input_parameter exception;
  pragma exception_init(e_invalid_input_parameter, c_error_code_invalid_input_parameter);
 
  -- Добавление или обновление данных платежа
  procedure insert_or_update_payment_detail (p_payment_id payment.payment_id%type,
                                             p_payment_detail t_payment_detail_array);
  -- Удаление деталей платежа                                          
  procedure delete_payment_detail (p_payment_id payment.payment_id%type,
                                   p_delete_detail_ids t_number_array);
end payment_detail_api_pack;
/