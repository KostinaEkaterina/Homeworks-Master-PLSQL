CREATE OR REPLACE package payment_detail_api_pack is
  /*
  Автор: Костина Екатерина
  Описание: API для сущностей “Детали платежа” 
  */
 
  -- добавление или обновление данных платежа
  procedure insert_or_update_payment_detail (p_payment_id payment.payment_id%type,
                                             p_payment_detail t_payment_detail_array);
  -- удаление деталей платежа                                          
  procedure delete_payment_detail (p_payment_id payment.payment_id%type,
                                   p_delete_detail_ids t_number_array);
  -- проверка, вызываемая из триггера
  procedure is_changes_through_api;
end payment_detail_api_pack;
/