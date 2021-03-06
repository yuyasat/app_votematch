class Mypage::QuestionsController < MypageController
  after_action :clear_session_errors, only: :show

  def index
    @question = Question.new
    @question.scores.new
    @questions = current_user.questions
    gon.parties = Party.active(Time.zone.now).pluck(:id)
  end

  def show
    @question = current_user.questions.find(params[:id])
    gon.parties = @question.scores.pluck(:party_id)
  rescue
    redirect_to mypage_path
  end

  def create
    question_set = current_user.question_sets.find(params[:question][:question_set])
    question_set.add_question(question_params)
    session[:errors] = question_set.questions.map(&:errors).map(&:full_messages).flatten
    handle_session(session)

    redirect_to mypage_question_set_path(question_set)
  end

  def update
    question = current_user.questions.find(params[:id])
    question.update(question_params)
    session[:errors] = question.errors.full_messages

    redirect_to mypage_question_path(question)
  end

  private

  def handle_session(session)
    if session[:errors].present?
      session[:scores_attributes] = question_params['scores_attributes'].to_h.map do |_k, v|
        [v['party_id'].to_i, v.except('party_id')]
      end.to_h
      session[:question_title] = question_params[:title]
    else
      session[:scores_attributes] = nil
      session[:question_title] = nil
    end
  end

  def question_params
    params.require(:question).permit(
      :user, :title, scores_attributes: %i(id party_id agree neutral opposition)
    )
  end
end
