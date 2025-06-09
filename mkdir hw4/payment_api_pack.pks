CREATE OR REPLACE package payment_api_pack is
  /*
  Автор: Костина Екатерина
  Описание: API для сущностей “Платеж”  
   */

  --статусы платежа
  c_new_status constant payment.status%type := 0;
  c_success_status constant payment.status%type := 1;
  c_error_status constant payment.status%type := 2;
  c_cancel_status constant payment.status%type := 3;
 
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
  --блокировка платежа для изменения
  procedure try_lock_payment (p_payment_id payment.payment_id%type);
  --триггеры
  procedure is_changes_through_api;
 
  procedure check_payment_delete_restriction;
end payment_api_pack;
/