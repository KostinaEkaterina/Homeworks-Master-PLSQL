CREATE OR REPLACE PACKAGE PLSQL14_STUDENT5.COMMON_PACK
AS
  --сообщения ошибок
  c_error_msg_empty_field_id    constant varchar2(100 char) := 'ID поля не может быть пустым';
  c_error_msg_empty_field_value constant varchar2(100 char) := 'Значение в поле не может быть пустым';
  c_error_msg_empty_collection  constant varchar2(100 char) := 'Коллекция не содержит данных';
  c_error_msg_empty_object_id   constant varchar2(100 char) := 'ID объекта не может быть пустым';
  c_error_msg_empty_reason      constant varchar2(100 char) := 'Причина не может быть пустой';
  c_error_msg_not_new_status    constant varchar2(100 char) := 'Статус платежа не в статусе "Создан". ID платежа: ';
  c_error_msg_delete_forbidden  constant varchar2(100 char) := 'Удаление объекта запрещено';
  c_error_msg_manual_changes    constant varchar2(100 char) := 'Изменения должны выполняться через API';
 
  -- коды ошибок
  c_error_code_invalid_input_parameter constant number(10) := -20101;
  c_error_code_invalid_payment_status  constant number(10) := -20102;
  c_error_code_delete_forbidden        constant number(10) := -20103;
  c_error_code_manual_changes          constant number(10) := -20104;
  c_error_code_empty_object_id         constant number(10) := -20105;
  c_error_code_empty_collection        constant number(10) := -20106; 
  -- объекты исключений
  e_invalid_input_parameter exception;
  pragma exception_init(e_invalid_input_parameter, c_error_code_invalid_input_parameter);
  e_delete_forbidden exception;
  pragma exception_init(e_delete_forbidden, c_error_code_delete_forbidden);
  e_manual_changes exception;
  pragma exception_init(e_manual_changes, c_error_code_manual_changes);
  e_empty_object_id exception;
  pragma exception_init(e_empty_object_id, c_error_code_empty_object_id);
  e_empty_collection exception;
  pragma exception_init(e_empty_collection, c_error_code_empty_collection);
  --включение\выключение разрешения менять вручную данные объектов
  procedure enable_manual_changes;
  procedure disable_manual_changes;  
 
  --разрешены ли ручные изменения на глобальном уровне
  function is_manual_changes_allowed return boolean;
END COMMON_PACK;
/