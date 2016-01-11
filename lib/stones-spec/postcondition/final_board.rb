module StonesSpec
  module Postcondition
    class FinalBoard < Errorable
      include StonesSpec::WithTempfile
      include StonesSpec::WithGbbHtmlRendering

      attr_reader :check_head_position, :show_initial_board

      def initialize(example, check_head_position, show_initial_board)
        super example
        @check_head_position = check_head_position
        @show_initial_board = show_initial_board
      end

      def do_validate(initial_board_gbb, actual_final_board_gbb, _result)
        if matches_with_expected_board? Stones::Gbb.read actual_final_board_gbb
          passed_result initial_board_gbb, actual_final_board_gbb
        else
          failed_result initial_board_gbb, example.final_board, actual_final_board_gbb
        end
      end

      private

      def failed_result(initial_board_gbb, expected_board_gbb, actual_board_gbb)
        boards = [
            ['Tablero final esperado', expected_board_gbb],
            ['Tablero final obtenido', actual_board_gbb]
        ]

        boards.unshift ['Tablero inicial', initial_board_gbb] if show_initial_board

        make_result boards, :failed
      end

      def passed_result(initial_board_gbb, actual_board_gbb)
        boards = [
            ['Tablero final', actual_board_gbb]
        ]

        boards.unshift ['Tablero inicial', initial_board_gbb] if show_initial_board

        make_result boards, :passed
      end

      def make_result(gbb_boards, status)
        boards = gbb_boards.map { |gbb_with_caption| get_html_board *gbb_with_caption }.join("\n")
        output = "<div>#{boards}</div>"
        [example.title, status, output]
      end

      def matches_with_expected_board?(actual_board)
        if check_head_position
          actual_board == final_board
        else
          actual_board.cells_equal? final_board
        end
      end

      def final_board
        Stones::Gbb.read example.final_board
      end
    end
  end
end