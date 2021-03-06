﻿using System.Linq;

namespace RohBot.Commands
{
    public class Sessions : Command
    {
        public override string Type { get { return "sessions"; } }

        public override string Format(CommandTarget target, string type) { return ""; }

        public override void Handle(CommandTarget target, string type, string[] parameters)
        {
            if (!target.IsWeb || !Util.IsSuperAdmin(target))
                return;

            var sessions = Program.SessionManager.List.Select(s => string.Format("{0} ({1})", s.Account.Name, s.ConnectionCount));
            var sessionsText = string.Join(", ", sessions);
            target.Send(string.Format("Sessions: {0}", sessionsText));
        }
    }
}
