module ApplicationHelper

     def alert_class(type)
    {error: "alert-error", notice: "alert-success", alert: "alert-info"}[type]
  end
  
    def menu_active(controller_name)
    "active" if controller.controller_path == controller_name
  end
end
