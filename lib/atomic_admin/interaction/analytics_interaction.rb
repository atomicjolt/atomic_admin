class AtomicAdmin::Interaction::AnalyticsInteraction < AtomicAdmin::Interaction::BaseInteraction
  group :application_instances
  key :analytics
  type :analytics
  title "Analytics"
  icon "bar_chart"
  order 0
end
