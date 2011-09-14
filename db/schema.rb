# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110923032509) do

  create_table "categories", :force => true do |t|
    t.string  "name"
    t.integer "parent_id"
  end

  add_index "categories", ["name"], :name => "index_categories_on_name"
  add_index "categories", ["parent_id"], :name => "index_categories_on_parent_id"

  create_table "collections", :force => true do |t|
    t.integer  "user_id",        :null => false
    t.string   "collection_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collections", ["user_id"], :name => "index_collections_on_user_id"

  create_table "exam_raters", :force => true do |t|
    t.datetime "created_at"
    t.string   "name"
    t.string   "mobilephone"
    t.string   "email"
    t.string   "author_code"
    t.integer  "examination_id"
  end

  add_index "exam_raters", ["author_code"], :name => "index_exam_raters_on_author_code"
  add_index "exam_raters", ["examination_id"], :name => "index_exam_raters_on_examination_id"

  create_table "exam_users", :force => true do |t|
    t.integer  "examination_id"
    t.integer  "user_id"
    t.string   "password"
    t.datetime "created_at"
    t.integer  "paper_id"
    t.datetime "started_at"
    t.datetime "submited_at"
    t.datetime "ended_at"
    t.boolean  "is_submited"
    t.boolean  "open_to_user"
    t.string   "answer_sheet_url"
    t.boolean  "is_user_affiremed"
    t.integer  "total_score"
    t.boolean  "is_auto_rate",      :default => false
    t.boolean  "is_free"
    t.integer  "correct_percent"
  end

  add_index "exam_users", ["examination_id"], :name => "index_exam_users_on_examination_id"
  add_index "exam_users", ["paper_id"], :name => "index_exam_users_on_paper_id"
  add_index "exam_users", ["user_id"], :name => "index_exam_users_on_user_id"

  create_table "examination_paper_relations", :force => true do |t|
    t.integer "examination_id"
    t.integer "paper_id"
  end

  add_index "examination_paper_relations", ["examination_id"], :name => "index_examination_paper_relations_on_examination_id"
  add_index "examination_paper_relations", ["paper_id"], :name => "index_examination_paper_relations_on_paper_id"

  create_table "examinations", :force => true do |t|
    t.string   "title"
    t.integer  "creater_id"
    t.string   "description"
    t.boolean  "is_score_open"
    t.boolean  "is_paper_open"
    t.string   "exam_password1"
    t.string   "exam_password2"
    t.datetime "start_at_time"
    t.datetime "start_end_time"
    t.integer  "exam_time"
    t.boolean  "is_published"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "user_affirm"
    t.integer  "status"
    t.integer  "price"
    t.datetime "get_free_end_at"
    t.datetime "exam_free_end_at"
    t.integer  "category_id"
    t.boolean  "is_should_rate"
    t.integer  "types"
  end

  add_index "examinations", ["creater_id"], :name => "index_examinations_on_creater_id"
  add_index "examinations", ["is_paper_open"], :name => "index_examinations_on_is_paper_open"
  add_index "examinations", ["is_score_open"], :name => "index_examinations_on_is_score_open"

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "status"
    t.text     "description"
    t.string   "answer"
    t.datetime "created_at"
    t.integer  "question_id"
  end

  add_index "feedbacks", ["status"], :name => "index_feedbacks_on_status"
  add_index "feedbacks", ["user_id"], :name => "index_feedbacks_on_user_id"

  create_table "model_roles", :force => true do |t|
    t.integer "role_id"
    t.integer "right_sum"
  end

  create_table "notes", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "note_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["user_id"], :name => "index_notes_on_user_id"

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "types"
    t.integer  "total_price"
    t.string   "remark"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "status"
  end

  create_table "paper_blocks", :force => true do |t|
    t.integer  "paper_id"
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time"
  end

  add_index "paper_blocks", ["paper_id"], :name => "index_paper_blocks_on_paper_id"

  create_table "papers", :force => true do |t|
    t.integer  "category_id"
    t.string   "title"
    t.integer  "creater_id"
    t.string   "description"
    t.integer  "total_score"
    t.integer  "total_question_num"
    t.boolean  "is_used"
    t.string   "paper_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "paper_js_url"
    t.integer  "types"
  end

  add_index "papers", ["category_id"], :name => "index_papers_on_category_id"
  add_index "papers", ["types"], :name => "index_papers_on_types"

  create_table "problem_tag_relations", :force => true do |t|
    t.integer "tag_id"
    t.integer "problem_id"
  end

  add_index "problem_tag_relations", ["problem_id"], :name => "index_problem_tag_relations_on_problem_id"
  add_index "problem_tag_relations", ["tag_id"], :name => "index_problem_tag_relations_on_tag_id"

  create_table "problem_tags", :force => true do |t|
    t.integer "problem_id"
    t.integer "total_num"
  end

  add_index "problem_tags", ["problem_id"], :name => "index_problem_tags_on_problem_id"

  create_table "problems", :force => true do |t|
    t.integer  "category_id"
    t.text     "title"
    t.integer  "types"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "complete_title"
    t.integer  "status"
  end

  add_index "problems", ["category_id"], :name => "index_problems_on_category_id"
  add_index "problems", ["types"], :name => "index_problems_on_types"

  create_table "question_tag_relations", :force => true do |t|
    t.integer "tag_id"
    t.integer "question_id"
  end

  add_index "question_tag_relations", ["question_id"], :name => "index_question_tag_relations_on_question_id"
  add_index "question_tag_relations", ["tag_id"], :name => "index_question_tag_relations_on_tag_id"

  create_table "questions", :force => true do |t|
    t.integer "problem_id"
    t.string  "description"
    t.string  "answer"
    t.integer "correct_type"
    t.text    "analysis"
    t.string  "question_attrs"
  end

  add_index "questions", ["correct_type"], :name => "index_questions_on_correct_type"
  add_index "questions", ["problem_id"], :name => "index_questions_on_problem_id"

  create_table "rater_user_relations", :force => true do |t|
    t.integer  "exam_user_id"
    t.integer  "exam_rater_id"
    t.boolean  "is_marked"
    t.boolean  "is_authed",     :default => false
    t.datetime "started_at"
    t.integer  "rate_time"
    t.boolean  "is_checked",    :default => false
  end

  add_index "rater_user_relations", ["exam_rater_id"], :name => "index_rater_user_relations_on_exam_rater_id"
  add_index "rater_user_relations", ["exam_user_id"], :name => "index_rater_user_relations_on_exam_user_id"
  add_index "rater_user_relations", ["is_marked"], :name => "index_rater_user_relations_on_is_marked"

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "score_levels", :force => true do |t|
    t.integer "examination_id"
    t.string  "key"
    t.string  "value"
  end

  add_index "score_levels", ["examination_id"], :name => "index_score_levels_on_examination_id"
  add_index "score_levels", ["key"], :name => "index_score_levels_on_key"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "num",  :default => 0
  end

  create_table "user_role_relations", :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "user_role_relations", ["role_id"], :name => "index_user_role_relations_on_role_id"
  add_index "user_role_relations", ["user_id"], :name => "index_user_role_relations_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "username"
    t.string   "mobilephone"
    t.string   "email"
    t.string   "address"
    t.string   "salt"
    t.string   "encrypted_password"
    t.integer  "status"
    t.string   "active_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "school"
    t.integer  "code_id"
    t.string   "code_type"
    t.integer  "belief"
  end

  add_index "users", ["code_id"], :name => "index_users_on_code_id"
  add_index "users", ["code_type"], :name => "index_users_on_code_type"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["status"], :name => "index_users_on_status"

end
