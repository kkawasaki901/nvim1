--[[
  -- HACK: pomo.nvimプラグイン（ポモドーロタイマー）
  
  {
    "epwalsh/pomo.nvim",
    version = "*",  -- Recommended, use latest release instead of latest commit
    lazy = true,
    cmd = {
    "TimerStart", "TimerStop", "TimerPause", "TimerResume",
    "TimerRepeat", "TimerSession",
    "PT",
    "FocusJsonReport", "FocusJsonReportAll",
    "FocusAdd", "FocusAddWork", "FocusAddRest",
    },
    dependencies = {
      -- Optional, but highly recommended if you want to use the "Default" timer
      "rcarriga/nvim-notify",
      "kkawasaki901/pomo-timer",
    },
    keys = {
    { "<leader>p", "<cmd>PT<CR>", desc = " pomodoro Commands", mode = "n" },
    },
    opts = {
      sessions = {
      -- usage: :TimerSession po
        po = {
          { name = "Work", duration = "20m" },
          { name = "Short Break", duration = "5m" },
        },
      },

      notifiers = {
        { name = "Default"},

        { init = FocusLogNotifier.new, 
          opts = {
            path = focus_json_path,
            log_stop = true, -- 停止時もログを残す
            min_minutes = 0, -- 1分未満は記録しない
          } 
        },

        {
          init = function(timer, opts)
          return require("pomo-timer").TestNotifier.new(timer, opts)
          end,
        },


      },
    },

    config = function(_, opts)
      require("pomo").setup(opts)
      local pomo_items = {
        { label = " TimerStart", cmd = "TimerStart", need_args = true },
        { label = " TimerStop", cmd = "TimerStop" },
        { label = " TimerPause", cmd = "TimerPause" },
        { label = " TimerResume", cmd = "TimerResume" },
        { label = " TimerSession po", cmd = "TimerSession po" },
        { label = " TimerSession any", cmd = "TimerSession", need_args = true },
        { label = " pomo_Report", cmd = "FocusJsonReport" },
        { label = "󰄭 pomo_ReportAll", cmd = "FocusJsonReportAll" },
        { label = " pomo_Add", cmd = "FocusAdd" },
        { label = "󰬱 pomo_AddWork", cmd = "FocusAddWork" },
        { label = "󰽺 pomo_AddRest", cmd = "FocusAddRest" },
      }
      -- :PTに割り当て
      vim.api.nvim_create_user_command("PT", function()
        vim.ui.select(pomo_items, {
          prompt = " pomo Timer Commands",
          format_item = function(item) return item.label end,
        }, function(choice)
          if choice then
            vim.cmd(choice.cmd)
          end
        end)
      end, {})
    end,
  },

  --]]