<script lang="ts">
	import type { UserProfile } from '$lib/types/user-profile';
	import SilentBadge from './SilentBadge.svelte';
	import { Hash, Hammer, Flame, Star } from 'lucide-svelte';
	import { getPrestigeName, getPrestigeColor } from '$lib/utils';

	let {
		user,
		showId = true,
		size = 'default'
	}: {
		user: UserProfile;
		showId?: boolean;
		size?: 'sm' | 'default';
	} = $props();

	let badgeClass = $derived(size === 'sm' ? 'text-xs' : '');
	let prestigeName = $derived(user.prestigeLevel ? getPrestigeName(user.prestigeLevel) : null);
	let prestigeColor = $derived(user.prestigeLevel ? getPrestigeColor(user.prestigeLevel) : 'text-gray-500');
</script>

<div class="flex items-center gap-1">
	{#if showId}
		<SilentBadge icon={Hash} class="text-muted-foreground {badgeClass}" text="#{user.id} to join" />
	{/if}
	{#if prestigeName}
		<SilentBadge icon={Star} text={prestigeName} class="{prestigeColor} {badgeClass}" />
	{/if}
	{#if user.loginStreak && user.loginStreak > 1}
		<SilentBadge
			icon={Flame}
			text="{user.loginStreak} day streak"
			class="text-orange-500 {badgeClass}"
		/>
	{/if}
	{#if user.isAdmin}
		<SilentBadge icon={Hammer} text="Admin" class="text-primary {badgeClass}" />
	{/if}
</div>
