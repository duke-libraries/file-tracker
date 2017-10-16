## Performed checks for `collection` scoped actions:
# can :index, Model         # included in :read
# can :new, Model           # included in :create
# can :export, Model
# can :history, Model       # for HistoryIndex
# can :destroy, Model       # for BulkDelete

## Performed checks for `member` scoped actions:
# can :show, Model, object            # included in :read
# can :edit, Model, object            # included in :update
# can :destroy, Model, object         # for Delete
# can :history, Model, object         # for HistoryShow
# can :show_in_app, Model, object

class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user = nil)
    @user = user || User.new

    can :dashboard, :all        # grant access to the dashboard
    can :access, :rails_admin   # grant access to rails_admin
    can :read, [ TrackedDirectory, TrackedFile, TrackedChange, FixityCheck ]

    can :manage, :all if admin?
  end

  def admin?
    user.respond_to?(:admin?) && user.admin?
  end

end
