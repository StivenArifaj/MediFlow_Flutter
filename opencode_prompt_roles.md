Please update the Sign Up page (`lib/features/auth/screens/register_screen.dart`) so the user can directly choose their role, rather than it just being a static, read-only badge.

Here is the context and detailed instructions:

### The 3 Roles
1. **Independent Patient** (`patient`): Manages their own medicines. (Theme: Neon Cyan `0xFF00E5FF`, Icon: `Icons.medication_rounded`, Emoji: 💊)
2. **Caregiver** (`caregiver`): Manages someone else's medicines. (Theme: Purple `0xFF8B5CF6`, Icon: `Icons.people_rounded`, Emoji: 🤝)
3. **Linked Patient** (`linked_patient`): Was invited by a caregiver and uses a 6-digit code. (Theme: Amber `0xFFFFB800` / Warning color, Icon: `Icons.link_rounded`, Emoji: 🔗)

### Instructions for the Update
1. **Remove Static Badge:** In `register_screen.dart`, find the static "Role badge" container (around line 188) and replace it with an interactive role selection component (e.g., a horizontally scrollable row of selectable pill-shaped chips or mini-cards).
2. **State Management:** Add a local state variable `String _selectedRole = 'patient';` (initialized to `repo.selectedRole ?? 'patient'`) and update it when the user taps a different role chip.
3. **Dynamic UI Rendering:** 
   - Ensure the selected role chip highlights with its respective theme color (Cyan for Patient, Purple for Caregiver, Amber for Linked).
   - If UI elements like the "Create Account" button gradient change based on the role, apply those styling updates.
4. **Linked Patient Logic:** Based on `PROJECT_LOG.md`, a Linked Patient skips the standard email/password registration and instead uses a 6-digit OTP invite code. 
   - If `_selectedRole == 'linked_patient'`, optionally hide the "Password" and "Confirm Password" fields or replace the "Create Account" button text with "Continue to Enter Code".
   - Under `_submit()`, if `_selectedRole == 'linked_patient'`, the app should navigate to `context.go('/enter-code')` instead of calling `repo.register()`.
5. **Database Alignment:** Make sure that when registering a patient or caregiver, the `role` parameter passed to `repo.register()` uses the active `_selectedRole`. Ensure that `users_table.dart` and `users` table logic correctly expects and supports these 3 role string values.
6. **Aesthetic Consistency:** Maintain the "Deep Space" visual design you created earlier (0xFF070B12 background, glassmorphism cards, glowing elements).

Please provide the fully updated `register_screen.dart` and any necessary updates to `users_table.dart`.
